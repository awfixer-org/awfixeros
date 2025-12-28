{ config, lib, ... }:
let
  cfg = config.system.awos;
in

{

  options.system = {

    awos.label = lib.mkOption {
      type = lib.types.strMatching "[a-zA-Z0-9:_\\.-]*";
      description = ''
        awos version name to be used in the names of generated
        outputs and boot labels.

        If you ever wanted to influence the labels in your GRUB menu,
        this is the option for you.

        It can only contain letters, numbers and the following symbols:
        `:`, `_`, `.` and `-`.

        The default is {option}`system.awos.tags` separated by
        "-" + "-" + {env}`awos_LABEL_VERSION` environment
        variable (defaults to the value of
        {option}`system.awos.version`).

        Can be overridden by setting {env}`awos_LABEL`.

        Useful for not loosing track of configurations built from different
        awos branches/revisions, e.g.:

        ```
        #!/bin/sh
        today=`date +%Y%m%d`
        branch=`(cd nixpkgs ; git branch 2>/dev/null | sed -n '/^\* / { s|^\* ||; p; }')`
        revision=`(cd nixpkgs ; git rev-parse HEAD)`
        export awos_LABEL_VERSION="$today.$branch-''${revision:0:7}"
        awos-rebuild switch
        ```
      '';
    };

    awos.tags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "with-xen" ];
      description = ''
        Strings to prefix to the default
        {option}`system.awos.label`.

        Useful for not losing track of configurations built with
        different options, e.g.:

        ```
        {
          system.awos.tags = [ "with-xen" ];
          virtualisation.xen.enable = true;
        }
        ```
      '';
    };

  };

  config = {
    # This is set here rather than up there so that changing it would
    # not rebuild the manual
    system.awos.label = lib.mkDefault (
      lib.maybeEnv "awos_LABEL" (
        lib.concatStringsSep "-" (
          (lib.sort (x: y: x < y) cfg.tags) ++ [ (lib.maybeEnv "awos_LABEL_VERSION" cfg.version) ]
        )
      )
    );
  };

}
