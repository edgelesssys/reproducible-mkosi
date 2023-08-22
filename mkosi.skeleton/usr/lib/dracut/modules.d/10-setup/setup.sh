#!/usr/bin/env bash

# not sure this is needed.

function depends() {
  # systemd-network-management expands to: systemd systemd-hostnamed systemd-networkd systemd-resolved systemd-timedated systemd-timesyncd
  echo dracut-systemd systemd-network-management systemd-veritysetup systemd-udevd
  return 0
}

function install() {
  return 0
}
