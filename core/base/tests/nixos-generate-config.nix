{ lib, ... }:
{
  name = "awos-generate-config";
  meta.maintainers = with lib.maintainers; [ basvandijk ];
  nodes.machine = {
    system.awos-generate-config.configuration = ''
      # OVERRIDDEN
      { config, pkgs, ... }: {
        imports = [ ./hardware-configuration.nix ];
      $bootLoaderConfig
      $desktopConfiguration
      }
    '';

    system.awos-generate-config.desktopConfiguration = [
      ''
        # DESKTOP
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;
      ''
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("awos-generate-config")

    machine.succeed("nix-instantiate --parse /etc/awos/configuration.nix /etc/awos/hardware-configuration.nix")

    # Test if the configuration really is overridden
    machine.succeed("grep 'OVERRIDDEN' /etc/awos/configuration.nix")

    # Test if desktop configuration really is overridden
    machine.succeed("grep 'DESKTOP' /etc/awos/configuration.nix")

    # Test of if the Perl variable $bootLoaderConfig is spliced correctly:
    machine.succeed(
        "grep 'boot\\.loader\\.grub\\.enable = true;' /etc/awos/configuration.nix"
    )

    # Test if the Perl variable $desktopConfiguration is spliced correctly
    machine.succeed(
        "grep 'services\\.desktopManager\\.gnome\\.enable = true;' /etc/awos/configuration.nix"
    )

    machine.succeed("rm -rf /etc/awos")
    machine.succeed("awos-generate-config --flake")
    machine.succeed("nix-instantiate --parse /etc/awos/flake.nix /etc/awos/configuration.nix /etc/awos/hardware-configuration.nix")

    machine.succeed("mv /etc/awos /etc/awos-with-flake-arg")
    machine.succeed("printf '[Defaults]\nFlake = 1\n' > /etc/awos-generate-config.conf")
    machine.succeed("awos-generate-config")
    machine.succeed("nix-instantiate --parse /etc/awos/flake.nix /etc/awos/configuration.nix /etc/awos/hardware-configuration.nix")
    machine.succeed("diff -r /etc/awos /etc/awos-with-flake-arg")
  '';
}
