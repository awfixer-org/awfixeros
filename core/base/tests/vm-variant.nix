{
  pkgs,
  ...
}:
let
  evalConfig = import ../lib/eval-config.nix;

  awos = evalConfig {
    modules = [
      {
        system.stateVersion = "25.05";
        fileSystems."/".device = "/dev/null";
        boot.loader.grub.device = "nodev";
        nixpkgs.hostPlatform = pkgs.system;
        virtualisation.vmVariant.networking.hostName = "vm";
        virtualisation.vmVariantWithBootLoader.networking.hostName = "vm-w-bl";
      }
    ];
  };
in
assert awos.config.virtualisation.vmVariant.networking.hostName == "vm";
assert awos.config.virtualisation.vmVariantWithBootLoader.networking.hostName == "vm-w-bl";
assert awos.config.networking.hostName == "awos";
pkgs.symlinkJoin {
  name = "awos-test-vm-variant-drvs";
  paths = with awos.config.system.build; [
    toplevel
    vm
    vmWithBootLoader
  ];
}
