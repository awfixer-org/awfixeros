{
  config,
  options,
  lib,
  pkgs,
  utils,
  modules,
  baseModules,
  extraModules,
  modulesPath,
  specialArgs,
  ...
}:

let
  inherit (lib)
    cleanSourceFilter
    concatMapStringsSep
    evalModules
    filter
    functionArgs
    hasSuffix
    isAttrs
    isDerivation
    isFunction
    isPath
    literalExpression
    mapAttrs
    mkIf
    mkMerge
    mkOption
    mkRemovedOptionModule
    mkRenamedOptionModule
    optional
    optionalAttrs
    optionals
    partition
    removePrefix
    types
    warn
    ;

  cfg = config.documentation;
  allOpts = options;

  canCacheDocs =
    m:
    let
      f = import m;
      instance = f (mapAttrs (n: _: abort "evaluating ${n} for `meta` failed") (functionArgs f));
    in
    cfg.awos.options.splitBuild
    && isPath m
    && isFunction f
    && instance ? options
    && instance.meta.buildDocsInSandbox or true;

  docModules =
    let
      p = partition canCacheDocs (baseModules ++ cfg.awos.extraModules);
    in
    {
      lazy = p.right;
      eager = p.wrong ++ optionals cfg.awos.includeAllModules (extraModules ++ modules);
    };

  manual = import ../../doc/manual rec {
    inherit pkgs config;
    version = config.system.awos.release;
    revision = "release-${version}";
    extraSources = cfg.awos.extraModuleSources;
    checkRedirects = cfg.awos.checkRedirects;
    options =
      let
        scrubbedEval = evalModules {
          modules = [
            {
              _module.check = false;
            }
          ]
          ++ docModules.eager;
          class = "awos";
          specialArgs = specialArgs // {
            pkgs = scrubDerivations "pkgs" pkgs;
            # allow access to arbitrary options for eager modules, eg for getting
            # option types from lazy modules
            options = allOpts;
            inherit modulesPath utils;
          };
        };
        scrubDerivations =
          namePrefix: pkgSet:
          mapAttrs (
            name: value:
            let
              wholeName = "${namePrefix}.${name}";
              guard = warn "Attempt to evaluate package ${wholeName} in option documentation; this is not supported and will eventually be an error. Use `mkPackageOption{,MD}` or `literalExpression` instead.";
            in
            if isAttrs value then
              scrubDerivations wholeName value
              // optionalAttrs (isDerivation value) {
                outPath = guard "\${${wholeName}}";
                drvPath = guard value.drvPath;
              }
            else
              value
          ) pkgSet;
      in
      scrubbedEval.options;

    baseOptionsJSON =
      let
        filter = builtins.filterSource (
          n: t:
          cleanSourceFilter n t
          && (t == "directory" -> baseNameOf n != "tests")
          && (t == "file" -> hasSuffix ".nix" n)
        );
        prefixRegex = "^" + lib.strings.escapeRegex (toString pkgs.path) + "($|/(modules|awos)($|/.*))";
        filteredModules = builtins.path {
          name = "source";
          inherit (pkgs) path;
          filter =
            n: t:
            builtins.match prefixRegex n != null
            && cleanSourceFilter n t
            && (t == "directory" -> baseNameOf n != "tests")
            && (t == "file" -> hasSuffix ".nix" n);
        };
      in
      pkgs.runCommand "lazy-options.json"
        rec {
          libPath = filter (pkgs.path + "/lib");
          pkgsLibPath = filter (pkgs.path + "/pkgs/pkgs-lib");
          awosPath = filteredModules + "/awos";
          NIX_ABORT_ON_WARN = warningsAreErrors;
          modules =
            "[ "
            + concatMapStringsSep " " (p: ''"${removePrefix "${modulesPath}/" (toString p)}"'') docModules.lazy
            + " ]";
          passAsFile = [ "modules" ];
          disallowedReferences = [
            filteredModules
            libPath
            pkgsLibPath
          ];
        }
        ''
          export NIX_STORE_DIR=$TMPDIR/store
          export NIX_STATE_DIR=$TMPDIR/state
          ${pkgs.buildPackages.nix}/bin/nix-instantiate \
            --show-trace \
            --eval --json --strict \
            --argstr libPath "$libPath" \
            --argstr pkgsLibPath "$pkgsLibPath" \
            --argstr awosPath "$awosPath" \
            --arg modules "import $modulesPath" \
            --argstr stateVersion "${options.system.stateVersion.default}" \
            --argstr release "${config.system.awos.release}" \
            $awosPath/lib/eval-cacheable-options.nix > $out \
            || {
              echo -en "\e[1;31m"
              echo 'Cacheable portion of option doc build failed.'
              echo 'Usually this means that an option attribute that ends up in documentation (eg' \
                '`default` or `description`) depends on the restricted module arguments' \
                '`config` or `pkgs`.'
              echo
              echo 'Rebuild your configuration with `--show-trace` to find the offending' \
                'location. Remove the references to restricted arguments (eg by escaping' \
                'their antiquotations or adding a `defaultText`) or disable the sandboxed' \
                'build for the failing module by setting `meta.buildDocsInSandbox = false`.'
              echo -en "\e[0m"
              exit 1
            } >&2
        '';

    inherit (cfg.awos.options) warningsAreErrors;
  };

  awos-help =
    let
      helpScript = pkgs.writeShellScriptBin "awos-help" ''
        # Finds first executable browser in a colon-separated list.
        # (see how xdg-open defines BROWSER)
        browser="$(
          IFS=: ; for b in $BROWSER; do
            [ -n "$(type -P "$b" || true)" ] && echo "$b" && break
          done
        )"
        if [ -z "$browser" ]; then
          browser="$(type -P xdg-open || true)"
          if [ -z "$browser" ]; then
            browser="${pkgs.w3m-nographics}/bin/w3m"
          fi
        fi
        exec "$browser" ${manual.manualHTMLIndex}
      '';

      desktopItem = pkgs.makeDesktopItem {
        name = "awos-manual";
        desktopName = "awos Manual";
        genericName = "System Manual";
        comment = "View awos documentation in a web browser";
        icon = "nix-snowflake";
        exec = "awos-help";
        categories = [ "System" ];
      };

    in
    pkgs.symlinkJoin {
      name = "awos-help";
      paths = [
        helpScript
        desktopItem
      ];
    };

in

{
  imports = [
    ./man-db.nix
    ./mandoc.nix
    ./assertions.nix
    ./meta.nix
    ../config/system-path.nix
    ../system/etc/etc.nix
    (mkRenamedOptionModule [ "programs" "info" "enable" ] [ "documentation" "info" "enable" ])
    (mkRenamedOptionModule [ "programs" "man" "enable" ] [ "documentation" "man" "enable" ])
    (mkRenamedOptionModule [ "services" "awosManual" "enable" ] [ "documentation" "awos" "enable" ])
    (mkRemovedOptionModule [
      "documentation"
      "awos"
      "options"
      "allowDocBook"
    ] "DocBook option documentation is no longer supported")
  ];

  options = {

    documentation = {

      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to install documentation of packages from
          {option}`environment.systemPackages` into the generated system path.

          See "Multiple-output packages" chapter in the nixpkgs manual for more info.
        '';
        # which is at ../../../doc/multiple-output.chapter.md
      };

      man.enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to install manual pages.
          This also includes `man` outputs.
        '';
      };

      man.generateCaches = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to generate the manual page index caches.
          This allows searching for a page or
          keyword using utilities like {manpage}`apropos(1)`
          and the `-k` option of
          {manpage}`man(1)`.
        '';
      };

      info.enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to install info pages and the {command}`info` command.
          This also includes "info" outputs.
        '';
      };

      doc.enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to install documentation distributed in packages' `/share/doc`.
          Usually plain text and/or HTML.
          This also includes "doc" outputs.
        '';
      };

      dev.enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install documentation targeted at developers.
          * This includes man pages targeted at developers if {option}`documentation.man.enable` is
            set (this also includes "devman" outputs).
          * This includes info pages targeted at developers if {option}`documentation.info.enable`
            is set (this also includes "devinfo" outputs).
          * This includes other pages targeted at developers if {option}`documentation.doc.enable`
            is set (this also includes "devdoc" outputs).
        '';
      };

      awos.enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to install awos's own documentation.

          - This includes man pages like
            {manpage}`configuration.nix(5)` if {option}`documentation.man.enable` is
            set.
          - This includes the HTML manual and the {command}`awos-help` command if
            {option}`documentation.doc.enable` is set.
        '';
      };

      awos.extraModules = mkOption {
        type = types.listOf types.raw;
        default = [ ];
        description = ''
          Modules for which to show options even when not imported.
        '';
      };

      awos.options.splitBuild = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to split the option docs build into a cacheable and an uncacheable part.
          Splitting the build can substantially decrease the amount of time needed to build
          the manual, but some user modules may be incompatible with this splitting.
        '';
      };

      awos.options.warningsAreErrors = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Treat warning emitted during the option documentation build (eg for missing option
          descriptions) as errors.
        '';
      };

      awos.includeAllModules = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether the generated awos's documentation should include documentation for all
          the options from all the awos modules included in the current
          `configuration.nix`. Disabling this will make the manual
          generator to ignore options defined outside of `baseModules`.
        '';
      };

      awos.extraModuleSources = mkOption {
        type = types.listOf (types.either types.path types.str);
        default = [ ];
        description = ''
          Which extra awos module paths the generated awos's documentation should strip
          from options.
        '';
        example = literalExpression ''
          # e.g. with options from modules in ''${pkgs.customModules}/nix:
          [ pkgs.customModules ]
        '';
      };

      awos.checkRedirects = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Check redirects for manualHTML.
        '';
      };

    };

  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.man.man-db.enable && cfg.man.mandoc.enable);
          message = ''
            man-db and mandoc can't be used as the default man page viewer at the same time!
          '';
        }
      ];
    }

    # The actual implementation for this lives in man-db.nix or mandoc.nix,
    # depending on which backend is active.
    (mkIf cfg.man.enable {
      environment.pathsToLink = [ "/share/man" ];
      environment.extraOutputsToInstall = [ "man" ] ++ optional cfg.dev.enable "devman";
    })

    (mkIf cfg.info.enable {
      environment.systemPackages = [ pkgs.texinfoInteractive ];
      environment.pathsToLink = [ "/share/info" ];
      environment.extraOutputsToInstall = [ "info" ] ++ optional cfg.dev.enable "devinfo";
      environment.extraSetup = ''
        if [ -w $out/share/info ]; then
          shopt -s nullglob
          for i in $out/share/info/*.info $out/share/info/*.info.gz; do
              ${pkgs.buildPackages.texinfo}/bin/install-info $i $out/share/info/dir
          done
        fi
      '';
    })

    (mkIf cfg.doc.enable {
      environment.pathsToLink = [
        "/share/doc"

        # Legacy paths used by gtk-doc & adjacent tools.
        "/share/gtk-doc"
        "/share/devhelp"
      ];
      environment.extraOutputsToInstall = [ "doc" ] ++ optional cfg.dev.enable "devdoc";
    })

    (mkIf cfg.awos.enable {
      system.build.manual = manual;

      environment.systemPackages =
        [ ]
        ++ optional cfg.man.enable manual.awos-configuration-reference-manpage
        ++ optionals cfg.doc.enable [
          manual.manualHTML
          awos-help
        ];
    })

  ]);

}
