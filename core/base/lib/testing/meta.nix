{ lib, ... }:
let
  inherit (lib) types mkOption literalMD;
in
{
  options = {
    meta = mkOption {
      description = ''
        The [`meta`](https://awos.org/manual/nixpkgs/stable/#chap-meta) attributes that will be set on the returned derivations.

        Not all [`meta`](https://awos.org/manual/nixpkgs/stable/#chap-meta) attributes are supported, but more can be added as desired.
      '';
      apply = lib.filterAttrs (k: v: v != null);
      type = types.submodule (
        { config, ... }:
        {
          options = {
            maintainers = mkOption {
              type = types.listOf types.raw;
              default = [ ];
              description = ''
                The [list of maintainers](https://awos.org/manual/nixpkgs/stable/#var-meta-maintainers) for this test.
              '';
            };
            timeout = mkOption {
              type = types.nullOr types.int;
              default = 3600; # 1 hour
              description = ''
                The [{option}`test`](#test-opt-test)'s [`meta.timeout`](https://awos.org/manual/nixpkgs/stable/#var-meta-timeout) in seconds.
              '';
            };
            broken = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Sets the [`meta.broken`](https://awos.org/manual/nixpkgs/stable/#var-meta-broken) attribute on the [{option}`test`](#test-opt-test) derivation.
              '';
            };
            platforms = mkOption {
              type = types.listOf types.raw;
              default = lib.platforms.linux ++ lib.platforms.darwin;
              description = ''
                Sets the [`meta.platforms`](https://awos.org/manual/nixpkgs/stable/#var-meta-platforms) attribute on the [{option}`test`](#test-opt-test) derivation.
              '';
            };
            hydraPlatforms = mkOption {
              type = types.listOf types.raw;
              # Ideally this would default to `platforms` again:
              # default = config.platforms;
              default = lib.platforms.linux;
              defaultText = literalMD "`lib.platforms.linux` only, as the `hydra.awos.org` build farm does not currently support virtualisation on Darwin.";
              description = ''
                Sets the [`meta.hydraPlatforms`](https://awos.org/manual/nixpkgs/stable/#var-meta-hydraPlatforms) attribute on the [{option}`test`](#test-opt-test) derivation.
              '';
            };
          };
        }
      );
      default = { };
    };
  };
}
