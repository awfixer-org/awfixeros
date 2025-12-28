# This module adds the calamares installer to the basic graphical awos
# installation CD.

{ pkgs, ... }:
let
  calamares-awos-autostart = pkgs.makeAutostartItem {
    name = "calamares";
    package = pkgs.calamares-awos;
  };
in
{
  imports = [ ./installation-cd-graphical-base.nix ];

  # required for kpmcore to work correctly
  programs.partition-manager.enable = true;

  environment.systemPackages = with pkgs; [
    # Calamares for graphical installation
    calamares-awos
    calamares-awos-autostart
    calamares-awos-extensions
    # Get list of locales
    glibcLocales
  ];

  # Support choosing from any locale
  i18n.supportedLocales = [ "all" ];
}
