{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.system.awos-init;
in
{
  options.system.awos-init = {
    enable = lib.mkEnableOption ''
      awos-init, a system for bashless initialization.

      This doesn't use any `activationScripts`. Anything set in these options is
      a no-op here.
    '';

    package = lib.mkPackageOption pkgs "awos-init" { };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.boot.initrd.systemd.enable;
        message = "awos-init can only be used with systemd initrd";
      }
    ];
  };
}
