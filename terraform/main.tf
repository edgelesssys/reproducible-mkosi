resource "aws_security_group" "instance" {
  name_prefix            = "nix-builder-${local.uid}-"
  description            = "Nix builder instance security group"
  revoke_rules_on_delete = true
}

resource "aws_security_group_rule" "ssh_in" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance.id
  description       = "Nix builder ssh access"
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  security_group_id = aws_security_group.instance.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Nix builder egress"
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "deployer-key-${local.uid}"
  public_key = file(var.install_ssh_pub_path)
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "nix-builder-${local.uid}"

  instance_type          = "c5d.4xlarge"
  key_name               = aws_key_pair.ec2_key.key_name
  monitoring             = true
  ami                    = data.aws_ami.amazon_linux.id
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "system-build" {
  source    = "git::https://github.com/nix-community/nixos-anywhere.git//terraform/nix-build?ref=bd3f79f11d030d9fa2cf18d3ad096dfdc98abcc8"
  attribute = var.nixos_system_attr
  file      = var.file
}

module "partitioner-build" {
  source    = "git::https://github.com/nix-community/nixos-anywhere.git//terraform/nix-build?ref=bd3f79f11d030d9fa2cf18d3ad096dfdc98abcc8"
  attribute = var.nixos_partitioner_attr
  file      = var.file
}

module "install" {
  source                      = "git::https://github.com/nix-community/nixos-anywhere.git//terraform/install?ref=bd3f79f11d030d9fa2cf18d3ad096dfdc98abcc8"
  kexec_tarball_url           = var.kexec_tarball_url
  target_user                 = local.install_user
  target_host                 = module.ec2_instance.public_ip
  target_port                 = var.target_port
  nixos_partitioner           = module.partitioner-build.result.out
  nixos_system                = module.system-build.result.out
  ssh_private_key             = file(var.install_ssh_key_path)
  debug_logging               = var.debug_logging
  stop_after_disko            = var.stop_after_disko
  extra_files_script          = var.extra_files_script
  disk_encryption_key_scripts = var.disk_encryption_key_scripts
  extra_environment           = var.extra_environment
  instance_id                 = var.instance_id
  # no_reboot                   = var.no_reboot
}

module "nixos-rebuild" {
  depends_on = [
    module.install
  ]

  # Do not execute this step if var.stop_after_disko == true
  count = var.stop_after_disko ? 0 : 1

  source          = "git::https://github.com/nix-community/nixos-anywhere.git//terraform/nixos-rebuild?ref=bd3f79f11d030d9fa2cf18d3ad096dfdc98abcc8"
  nixos_system    = module.system-build.result.out
  ssh_private_key = file(var.deployment_ssh_key_path)
  target_host     = module.ec2_instance.public_ip
  target_user     = var.target_user
}

resource "random_id" "uid" {
  byte_length = 8
}

locals {
  uid          = random_id.uid.hex
  install_user = var.install_user == null ? var.target_user : var.install_user
}
