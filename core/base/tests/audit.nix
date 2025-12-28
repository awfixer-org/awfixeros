{ lib, ... }:
{

  name = "audit";

  meta = {
    maintainers = with lib.maintainers; [ grimmauld ];
  };

  nodes = {
    machine =
      { lib, pkgs, ... }:
      {
        security.audit = {
          enable = true;
          rules = [
            "-a always,exit -F exe=${lib.getExe pkgs.hello} -k awos-test"
          ];
          backlogLimit = 512;
        };
        security.auditd = {
          enable = true;
          plugins.af_unix.active = true;
          plugins.syslog.active = true;
          # plugins.remote.active = true; # needs configuring a remote server for logging
          # plugins.filter.active = true; # needs configuring allowlist/denylist
        };

        environment.systemPackages = [ pkgs.hello ];
      };
  };

  testScript = ''
    machine.wait_for_unit("audit-rules-awos.service")
    machine.wait_for_unit("auditd.service")

    with subtest("Audit subsystem gets enabled"):
      audit_status = machine.succeed("auditctl -s")
      t.assertIn("enabled 1", audit_status)
      t.assertIn("backlog_limit 512", audit_status)

    with subtest("unix socket plugin activated"):
      machine.succeed("stat /run/audit/audispd_events")

    with subtest("Custom rule produces audit traces"):
      machine.succeed("hello")
      print(machine.succeed("ausearch -k awos-test -sc exit_group"))

    with subtest("Stopping audit-rules-awos.service disables the audit subsystem"):
      machine.succeed("systemctl stop audit-rules-awos.service")
      t.assertIn("enabled 0", machine.succeed("auditctl -s"))
  '';

}
