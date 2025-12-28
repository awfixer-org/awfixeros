# A module containing the base imports and overrides that
# are always applied in awos VM tests, unconditionally,
# even in `inheritParentConfig = false` specialisations.
{ lib, ... }:
let
  inherit (lib) mkDefault mkForce;
in
{
  imports = [
    ../../modules/virtualisation/qemu-vm.nix
    ../../modules/testing/test-instrumentation.nix # !!! should only get added for automated test runs
    {
      key = "no-manual";
      documentation.awos.enable = false;
    }
    {
      key = "no-revision";
      # Make the revision metadata constant, in order to avoid needless retesting.
      # The human version (e.g. 21.05-pre) is left as is, because it is useful
      # for external modules that test with e.g. testers.awosTest and rely on that
      # version number.
      config.system.awos = {
        revision = mkForce "constant-awos-revision";
        versionSuffix = mkForce "test";
        label = mkForce "test";
      };
    }
    (
      { config, ... }:
      {
        # Don't pull in switch-to-configuration by default, except when specialisations or early boot shenanigans are involved.
        # This is mostly a Hydra optimization, so we don't rebuild all the tests every time switch-to-configuration-ng changes.
        key = "no-switch-to-configuration";
        system.switch.enable = mkDefault (
          config.isSpecialisation || config.specialisation != { } || config.virtualisation.installBootLoader
        );
      }
    )
  ];
}
