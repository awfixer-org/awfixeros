# DO NOT IMPORT. Use nixpkgsFlake.lib.awos, or import (nixpkgs + "/awos/lib")
{ lib }: # read -^

let

  /*
    Invoke awos. Unlike traditional awos, this does not include all modules.
    Any such modules have to be explicitly added via the `modules` parameter,
    or imported using `imports` in a module.

    A minimal module list improves awos evaluation performance and allows
    modules to be independently usable, supporting new use cases.

    Parameters:

      modules:        A list of modules that constitute the configuration.

      specialArgs:    An attribute set of module arguments. Unlike
                      `config._module.args`, these are available for use in
                      `imports`.
                      `config._module.args` should be preferred when possible.

    Return:

      An attribute set containing `config.system.build.toplevel` among other
      attributes. See `lib.evalModules` in the Nixpkgs library.
  */
  evalModules =
    {
      prefix ? [ ],
      modules ? [ ],
      specialArgs ? { },
    }:
    # NOTE: Regular awos currently does use this function! Don't break it!
    #       Ideally we don't diverge, unless we learn that we should.
    #       In other words, only the public interface of awos.evalModules
    #       is experimental.
    lib.evalModules {
      inherit prefix modules;
      class = "awos";
      specialArgs = {
        modulesPath = builtins.toString ../modules;
      }
      // specialArgs;
    };

in
{
  inherit evalModules;
}
