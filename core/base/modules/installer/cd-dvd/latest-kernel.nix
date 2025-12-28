{ lib, pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems.zfs = false;
  environment.etc."awos-generate-config.conf".text = ''
    [Defaults]
    Kernel=latest
  '';
}
