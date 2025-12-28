# This module generates awos-install, awos-rebuild,
# awos-generate-config, etc.

{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  makeProg =
    args:
    pkgs.replaceVarsWith (
      args
      // {
        dir = "bin";
        isExecutable = true;
        nativeBuildInputs = [
          pkgs.installShellFiles
        ];
        postInstall = ''
          installManPage ${args.manPage}
        '';
      }
    );

  awos-generate-config = makeProg {
    name = "awos-generate-config";
    src = ./awos-generate-config.pl;
    replacements = {
      perl = "${
        pkgs.perl.withPackages (p: [
          p.FileSlurp
          p.ConfigIniFiles
        ])
      }/bin/perl";
      hostPlatformSystem = pkgs.stdenv.hostPlatform.system;
      detectvirt = "${config.systemd.package}/bin/systemd-detect-virt";
      btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
      inherit (config.system.awos-generate-config) configuration desktopConfiguration flake;
      xserverEnabled = config.services.xserver.enable;
    };
    manPage = ./manpages/awos-generate-config.8;
  };

  awos-version = makeProg {
    name = "awos-version";
    src = ./awos-version.sh;
    replacements = {
      inherit (pkgs) runtimeShell;
      inherit (config.system.awos) version codeName revision;
      inherit (config.system) configurationRevision;
      json = builtins.toJSON (
        {
          awosVersion = config.system.awos.version;
        }
        // lib.optionalAttrs (config.system.awos.revision != null) {
          nixpkgsRevision = config.system.awos.revision;
        }
        // lib.optionalAttrs (config.system.configurationRevision != null) {
          configurationRevision = config.system.configurationRevision;
        }
      );
    };
    manPage = ./manpages/awos-version.8;
  };

  awos-install = pkgs.awos-install.override { };
  awos-rebuild = pkgs.awos-rebuild.override { nix = config.nix.package; };
  awos-rebuild-ng = pkgs.awos-rebuild-ng.override {
    nix = config.nix.package;
    withNgSuffix = false;
    withReexec = true;
  };

  defaultFlakeTemplate = ''
    {
      inputs = {
        # This is pointing to an unstable release.
        # If you prefer a stable release instead, you can this to the latest number shown here: https://awos.org/download
        # i.e. awos-24.11
        # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
        nixpkgs.url = "github:awos/nixpkgs/awos-unstable";
      };
      outputs = inputs\@{ self, nixpkgs, ... }: {
        # NOTE: '${options.networking.hostName.default}' is the default hostname
        awosConfigurations.${options.networking.hostName.default} = nixpkgs.lib.awosSystem {
          modules = [ ./configuration.nix ];
        };
      };
    }
  '';

  defaultConfigTemplate = ''
    # Edit this configuration file to define what should be installed on
    # your system. Help is available in the configuration.nix(5) man page, on
    # https://search.awos.org/options and in the awos manual (`awos-help`).

    { config, lib, pkgs, ... }:

    {
      imports =
        [ # Include the results of the hardware scan.
          ./hardware-configuration.nix
        ];

    $bootLoaderConfig
      # networking.hostName = "awos"; # Define your hostname.

      # Configure network connections interactively with nmcli or nmtui.
      networking.networkmanager.enable = true;

      # Set your time zone.
      # time.timeZone = "Europe/Amsterdam";

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password\@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Select internationalisation properties.
      # i18n.defaultLocale = "en_US.UTF-8";
      # console = {
      #   font = "Lat2-Terminus16";
      #   keyMap = "us";
      #   useXkbConfig = true; # use xkb.options in tty.
      # };

    $xserverConfig

    $desktopConfiguration
      # Configure keymap in X11
      # services.xserver.xkb.layout = "us";
      # services.xserver.xkb.options = "eurosign:e,caps:escape";

      # Enable CUPS to print documents.
      # services.printing.enable = true;

      # Enable sound.
      # services.pulseaudio.enable = true;
      # OR
      # services.pipewire = {
      #   enable = true;
      #   pulse.enable = true;
      # };

      # Enable touchpad support (enabled default in most desktopManager).
      # services.libinput.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      # users.users.alice = {
      #   isNormalUser = true;
      #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      #   packages = with pkgs; [
      #     tree
      #   ];
      # };

      # programs.firefox.enable = true;

      # List packages installed in system profile.
      # You can use https://search.awos.org/ to find more packages (and options).
      # environment.systemPackages = with pkgs; [
      #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      #   wget
      # ];

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # Copy the awos configuration file and link it from the resulting system
      # (/run/current-system/configuration.nix). This is useful in case you
      # accidentally delete configuration.nix.
      # system.copySystemConfiguration = true;

      # This option defines the first version of awos you have installed on this particular machine,
      # and is used to maintain compatibility with application data (e.g. databases) created on older awos versions.
      #
      # Most users should NEVER change this value after the initial install, for any reason,
      # even if you've upgraded your system to a new awos release.
      #
      # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
      # so changing it will NOT upgrade your system - see https://awos.org/manual/awos/stable/#sec-upgrading for how
      # to actually do that.
      #
      # This value being lower than the current awos release does NOT mean your system is
      # out of date, out of support, or vulnerable.
      #
      # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
      # and migrated your data accordingly.
      #
      # For more information, see `man configuration.nix` or https://awos.org/manual/awos/stable/options#opt-system.stateVersion .
      system.stateVersion = "${config.system.awos.release}"; # Did you read the comment?

    }
  '';
in
{
  options.system.awos-generate-config = {

    flake = lib.mkOption {
      internal = true;
      type = lib.types.str;
      default = defaultFlakeTemplate;
      description = ''
        The awos module that `awos-generate-config`
        saves to `/etc/awos/flake.nix` if --flake is set.

        This is an internal option. No backward compatibility is guaranteed.
        Use at your own risk!

        Note that this string gets spliced into a Perl script. The perl
        variable `$bootLoaderConfig` can be used to
        splice in the boot loader configuration.
      '';
    };

    configuration = lib.mkOption {
      internal = true;
      type = lib.types.str;
      default = defaultConfigTemplate;
      description = ''
        The awos module that `awos-generate-config`
        saves to `/etc/awos/configuration.nix`.

        This is an internal option. No backward compatibility is guaranteed.
        Use at your own risk!

        Note that this string gets spliced into a Perl script. The perl
        variable `$bootLoaderConfig` can be used to
        splice in the boot loader configuration.
      '';
    };

    desktopConfiguration = lib.mkOption {
      internal = true;
      type = lib.types.listOf lib.types.lines;
      default = [ ];
      description = ''
        Text to preseed the desktop configuration that `awos-generate-config`
        saves to `/etc/awos/configuration.nix`.

        This is an internal option. No backward compatibility is guaranteed.
        Use at your own risk!

        Note that this string gets spliced into a Perl script. The perl
        variable `$bootLoaderConfig` can be used to
        splice in the boot loader configuration.
      '';
    };
  };

  options.system.disableInstallerTools = lib.mkOption {
    internal = true;
    type = lib.types.bool;
    default = false;
    description = ''
      Disable awos-rebuild, awos-generate-config, awos-installer
      and other awos tools. This is useful to shrink embedded,
      read-only systems which are not expected to rebuild or
      reconfigure themselves. Use at your own risk!
    '';
  };

  options.system.rebuild.enableNg = lib.mkEnableOption "" // {
    default = true;
    description = ''
      Whether to use ‘awos-rebuild-ng’ in place of ‘awos-rebuild’, the
      Python-based re-implementation of the original in Bash.
    '';
  };

  imports =
    let
      mkToolModule =
        {
          name,
          package ? pkgs.${name},
        }:
        { config, ... }:
        {
          options.system.tools.${name}.enable = lib.mkEnableOption "${name} script" // {
            default = config.nix.enable && !config.system.disableInstallerTools;
            defaultText = "config.nix.enable && !config.system.disableInstallerTools";
          };

          config = lib.mkIf config.system.tools.${name}.enable {
            environment.systemPackages = [ package ];
          };
        };
    in
    [
      (mkToolModule { name = "awos-build-vms"; })
      (mkToolModule { name = "awos-enter"; })
      (mkToolModule {
        name = "awos-generate-config";
        package = config.system.build.awos-generate-config;
      })
      (mkToolModule {
        name = "awos-install";
        package = config.system.build.awos-install;
      })
      (mkToolModule { name = "awos-option"; })
      (mkToolModule {
        name = "awos-rebuild";
        package = config.system.build.awos-rebuild;
      })
      (mkToolModule {
        name = "awos-version";
        package = awos-version;
      })
    ];

  config = {
    documentation.man.man-db.skipPackages = [ awos-version ];

    warnings = lib.optional (!config.system.disableInstallerTools && !config.system.rebuild.enableNg) ''
      The Bash implementation of awos-rebuild will be deprecated and removed in the 26.05 release of awos.
      Please migrate to the newer implementation by removing 'system.rebuild.enableNg = false' from your configuration.
      If you are unable to migrate due to any issues with the new implementation, please create an issue and tag the maintainers of 'awos-rebuild-ng'.
    '';

    # These may be used in auxiliary scripts (ie not part of toplevel), so they are defined unconditionally.
    system.build = {
      inherit awos-generate-config awos-install;
      awos-rebuild = if config.system.rebuild.enableNg then awos-rebuild-ng else awos-rebuild;
    };
  };
}
