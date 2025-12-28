{
  pkgs,
  latestKernel ? false,
  ...
}:

{
  name = "disable-installer-tools";

  nodes.machine =
    { pkgs, lib, ... }:
    {
      system.disableInstallerTools = true;
      environment.defaultPackages = [ ];
    };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.wait_until_succeeds("pgrep -f 'agetty.*tty1'")

    with subtest("awos installer tools should not be included"):
        machine.fail("which awos-rebuild")
        machine.fail("which awos-install")
        machine.fail("which awos-generate-config")
        machine.fail("which awos-enter")
        machine.fail("which awos-version")
        machine.fail("which awos-build-vms")

    with subtest("perl should not be included"):
        machine.fail("which perl")
  '';
}
