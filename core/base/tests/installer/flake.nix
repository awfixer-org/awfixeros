# This file gets copied into the installation

{
  # To keep things simple, we'll use an absolute path dependency here.
  inputs.nixpkgs.url = "@nixpkgs@";

  outputs =
    { nixpkgs, ... }:
    {

      awosConfigurations.xyz = nixpkgs.lib.awosSystem {
        modules = [
          ./configuration.nix
          (nixpkgs + "/awos/modules/testing/test-instrumentation.nix")
          {
            # We don't need nix-channel anymore
            nix.channel.enable = false;
          }
        ];
      };
    };
}
