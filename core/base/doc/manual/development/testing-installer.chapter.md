# Testing the Installer {#ch-testing-installer}

Building, burning, and booting from an installation CD is rather
tedious, so here is a quick way to see if the installer works properly:

```ShellSession
# mount -t tmpfs none /mnt
# awos-generate-config --root /mnt
$ nix-build '<nixpkgs>' -A awos-install
# ./result/bin/awos-install
```

To start a login shell in the new awos installation in `/mnt`:

```ShellSession
$ nix-build '<nixpkgs>' -A awos-enter
# ./result/bin/awos-enter
```
