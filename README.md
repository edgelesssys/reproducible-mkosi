<h1 align="center">Reproducible mkosi</h1>
<h3 align="center">Build bit-by-bit reproducible OS images</h3>
<br>
<br>
<br>

[mkosi](https://github.com/systemd/mkosi) is a tool for building customized OS images.
This repository shows how to use [Nix](https://nixos.org/) to pin mkosi and required
tools and build bit-by-bit reproducible OS images.


### History of getting and keeping this reproducible

Hours of debugging went into making this fully reproducible, and there are still things left to do,
especially regarding the handling of packages pulled in by the package manger of the target distro.
In the following, we list some work we did upstream that explicitly fix reproducibility issues.

- [**systemd/mkosi** propagate SOURCE_DATE_EPOCH when calling systemd-repart](https://github.com/systemd/mkosi/pull/1834)
- [**systemd/mkosi** add config setting seed to set systemd-repart --seed](https://github.com/systemd/mkosi/pull/1837)
- [**systemd/mkosi** normalize mtime](https://github.com/systemd/mkosi/pull/1839)
- [**systemd/mkosi** make_tar: do not emit extended PAX headers for atime, ctime and mtime](https://github.com/systemd/mkosi/pull/1982)
- [**systemd/mkosi** make_cpio: sort files used as cpio input](https://github.com/systemd/mkosi/pull/2163)
- [**systemd/mkosi** "-C" flag results in inconsistent relative path handling](https://github.com/systemd/mkosi/issues/1879)
- [**systemd/systemd** repart: temporary hardlink store leaks into final image when host uses btrfs](https://github.com/systemd/systemd/issues/29606)
- [**systemd/systemd** mkfs-util: propagate SOURCE_DATE_EPOCH to mcopy](https://github.com/systemd/systemd/pull/29000)
- [**authselect/authselect** remove timestamp from generated files](https://github.com/authselect/authselect/pull/350)
- [**NixOS/nixpkgs** dosfstools: backport reproducible builds patch](https://github.com/NixOS/nixpkgs/pull/252282)
