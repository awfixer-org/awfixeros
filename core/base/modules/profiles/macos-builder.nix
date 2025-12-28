let
  lib = import ../../../lib;
in
lib.warnIf (lib.isInOldestRelease 2411)
  "awos/modules/profiles/macos-builder.nix has moved to awos/modules/profiles/nix-builder-vm.nix; please update your awos imports."
  ./nix-builder-vm.nix
