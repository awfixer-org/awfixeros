# This module defines a awos installation CD that contains Plasma 6.

{ lib, pkgs, ... }:

{
  imports = [ ./installation-cd-graphical-calamares.nix ];

  isoImage.edition = lib.mkDefault "plasma6";

  services.desktopManager.plasma6.enable = true;

  # Automatically login as awos.
  services.displayManager = {
    sddm.enable = true;
    autoLogin = {
      enable = true;
      user = "awos";
    };
  };

  environment.systemPackages = [
    # FIXME: using Qt5 builds of Maliit as upstream has not ported to Qt6 yet
    pkgs.maliit-framework
    pkgs.maliit-keyboard
  ];

  environment.plasma6.excludePackages = [
    # Optional wallpapers that add 126 MiB to the graphical installer
    # closure. They will still need to be downloaded when installing a
    # Plasma system, though.
    pkgs.kdePackages.plasma-workspace-wallpapers
  ];

  # Avoid bundling an entire MariaDB installation on the ISO.
  programs.kde-pim.enable = false;

  system.activationScripts.installerDesktop =
    let

      # Comes from documentation.nix when xserver and awos.enable are true.
      manualDesktopFile = "/run/current-system/sw/share/applications/awos-manual.desktop";

      homeDir = "/home/awos/";
      desktopDir = homeDir + "Desktop/";

    in
    ''
      mkdir -p ${desktopDir}
      chown awos ${homeDir} ${desktopDir}

      ln -sfT ${manualDesktopFile} ${desktopDir + "awos-manual.desktop"}
      ln -sfT ${pkgs.gparted}/share/applications/gparted.desktop ${desktopDir + "gparted.desktop"}
      ln -sfT ${pkgs.calamares-awos}/share/applications/calamares.desktop ${
        desktopDir + "calamares.desktop"
      }
    '';

}
