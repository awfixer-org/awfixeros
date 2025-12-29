{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/awos-unstable";
    awos-lib = {
      url = "github:awfixer-os/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awos-modules = {
      url = "github:awfixer-os/awos-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    icicle = {
      url = "github:awfixer-os/icicle";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-data = {
      url = "github:awfixer-os/nix-data";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake rec {
      inherit inputs;
      channels-config.allowUnfree = true;

      systems.modules.nixos = with inputs; [
        nix-data.nixosModules.nix-data
        icicle.nixosModules.icicle
        awos-modules.nixosModules.awos-de
        awos-modules.nixosModules.kernel
        awos-modules.nixosModules.networking
        awos-modules.nixosModules.pipewire
        awos-modules.nixosModules.printing
        awos-modules.nixosModules.awos
        awos-modules.nixosModules.metadata
      ];

      src = ./.;
    };
}
