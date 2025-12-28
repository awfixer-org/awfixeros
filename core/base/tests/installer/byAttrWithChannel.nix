# This file gets copied into the installation

{
  evalConfig ? import <nixpkgs/awos/lib/eval-config.nix>,
}:

evalConfig {
  modules = [
    ./configuration.nix
    (import <nixpkgs/awos/modules/testing/test-instrumentation.nix>)
  ];
}
