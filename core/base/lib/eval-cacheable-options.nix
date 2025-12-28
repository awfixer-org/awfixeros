{
  libPath,
  pkgsLibPath,
  awosPath,
  modules,
  stateVersion,
  release,
}:

let
  lib = import libPath;
  modulesPath = "${awosPath}/modules";
  # dummy pkgs set that contains no packages, only `pkgs.lib` from the full set.
  # not having `pkgs.lib` causes all users of `pkgs.formats` to fail.
  pkgs = import pkgsLibPath {
    inherit lib;
    pkgs = null;
  };
  utils = import "${awosPath}/lib/utils.nix" {
    inherit config lib;
    pkgs = null;
  };
  # this is used both as a module and as specialArgs.
  # as a module it sets the _module special values, as specialArgs it makes `config`
  # unusable. this causes documentation attributes depending on `config` to fail.
  config = {
    _module.check = false;
    _module.args = { };
    system.stateVersion = stateVersion;
  };
  eval = lib.evalModules {
    modules = (map (m: "${modulesPath}/${m}") modules) ++ [
      config
    ];
    specialArgs = {
      inherit config pkgs utils;
      class = "awos";
    };
  };
  docs = import "${awosPath}/doc/manual" {
    pkgs = pkgs // {
      inherit lib;
      # duplicate of the declaration in all-packages.nix
      buildPackages.awosOptionsDoc =
        attrs: (import "${awosPath}/lib/make-options-doc") ({ inherit pkgs lib; } // attrs);
    };
    config = config.config;
    options = eval.options;
    version = release;
    revision = "release-${release}";
    prefix = modulesPath;
    extraSources = [ (dirOf awosPath) ];
  };
in
docs.optionsNix
