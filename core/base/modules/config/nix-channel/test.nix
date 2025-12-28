# Run:
#   nix-build -A awosTests.nix-channel
{ lib, testers }:
let
  inherit (lib) fileset;

  runShellcheck = testers.shellcheck {
    name = "activation-check";
    src = fileset.toSource {
      root = ./.;
      fileset = fileset.unions [
        ./activation-check.sh
      ];
    };
  };

in
lib.recurseIntoAttrs {
  inherit runShellcheck;
}
