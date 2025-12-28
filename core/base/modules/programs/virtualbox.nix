let
  msg =
    "Importing <nixpkgs/awos/modules/programs/virtualbox.nix> is "
    + "deprecated, please use `virtualisation.virtualbox.host.enable = true' "
    + "instead.";
in
{
  config.warnings = [ msg ];
  config.virtualisation.virtualbox.host.enable = true;
}
