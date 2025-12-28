/*
  This module enables a simple firewall.

  The firewall can be customised in arbitrary ways by setting
  ‘networking.firewall.extraCommands’.  For modularity, the firewall
  uses several chains:

  - ‘awos-fw’ is the main chain for input packet processing.

  - ‘awos-fw-accept’ is called for accepted packets.  If you want
  additional logging, or want to reject certain packets anyway, you
  can insert rules at the start of this chain.

  - ‘awos-fw-log-refuse’ and ‘awos-fw-refuse’ are called for
  refused packets.  (The former jumps to the latter after logging
  the packet.)  If you want additional logging, or want to accept
  certain packets anyway, you can insert rules at the start of
  this chain.

  - ‘awos-fw-rpfilter’ is used as the main chain in the mangle table,
  called from the built-in ‘PREROUTING’ chain.  If the kernel
  supports it and `cfg.checkReversePath` is set this chain will
  perform a reverse path filter test.

  - ‘awos-drop’ is used while reloading the firewall in order to drop
  all traffic.  Since reloading isn't implemented in an atomic way
  this'll prevent any traffic from leaking through while reloading
  the firewall.  However, if the reloading fails, the ‘firewall-stop’
  script will be called which in return will effectively disable the
  complete firewall (in the default configuration).
*/
{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.networking.firewall;

  inherit (config.boot.kernelPackages) kernel;

  kernelHasRPFilter =
    ((kernel.config.isEnabled or (x: false)) "IP_NF_MATCH_RPFILTER")
    || (kernel.features.netfilterRPFilter or false);

  helpers = import ./helpers.nix { inherit config lib; };

  writeShScript =
    name: text:
    let
      dir = pkgs.writeScriptBin name ''
        #! ${pkgs.runtimeShell} -e
        ${text}
      '';
    in
    "${dir}/bin/${name}";

  startScript = writeShScript "firewall-start" ''
    ${helpers}

    # Flush the old firewall rules.  !!! Ideally, updating the
    # firewall would be atomic.  Apparently that's possible
    # with iptables-restore.
    ip46tables -D INPUT -j awos-fw 2> /dev/null || true
    for chain in awos-fw awos-fw-accept awos-fw-log-refuse awos-fw-refuse; do
      ip46tables -F "$chain" 2> /dev/null || true
      ip46tables -X "$chain" 2> /dev/null || true
    done


    # The "awos-fw-accept" chain just accepts packets.
    ip46tables -N awos-fw-accept
    ip46tables -A awos-fw-accept -j ACCEPT


    # The "awos-fw-refuse" chain rejects or drops packets.
    ip46tables -N awos-fw-refuse

    ${
      if cfg.rejectPackets then
        ''
          # Send a reset for existing TCP connections that we've
          # somehow forgotten about.  Send ICMP "port unreachable"
          # for everything else.
          ip46tables -A awos-fw-refuse -p tcp ! --syn -j REJECT --reject-with tcp-reset
          ip46tables -A awos-fw-refuse -j REJECT
        ''
      else
        ''
          ip46tables -A awos-fw-refuse -j DROP
        ''
    }


    # The "awos-fw-log-refuse" chain performs logging, then
    # jumps to the "awos-fw-refuse" chain.
    ip46tables -N awos-fw-log-refuse

    ${lib.optionalString cfg.logRefusedConnections ''
      ip46tables -A awos-fw-log-refuse -p tcp --syn -j LOG --log-level info --log-prefix "refused connection: "
    ''}
    ${lib.optionalString (cfg.logRefusedPackets && !cfg.logRefusedUnicastsOnly) ''
      ip46tables -A awos-fw-log-refuse -m pkttype --pkt-type broadcast \
        -j LOG --log-level info --log-prefix "refused broadcast: "
      ip46tables -A awos-fw-log-refuse -m pkttype --pkt-type multicast \
        -j LOG --log-level info --log-prefix "refused multicast: "
    ''}
    ip46tables -A awos-fw-log-refuse -m pkttype ! --pkt-type unicast -j awos-fw-refuse
    ${lib.optionalString cfg.logRefusedPackets ''
      ip46tables -A awos-fw-log-refuse \
        -j LOG --log-level info --log-prefix "refused packet: "
    ''}
    ip46tables -A awos-fw-log-refuse -j awos-fw-refuse


    # The "awos-fw" chain does the actual work.
    ip46tables -N awos-fw

    # Clean up rpfilter rules
    ip46tables -t mangle -D PREROUTING -j awos-fw-rpfilter 2> /dev/null || true
    ip46tables -t mangle -F awos-fw-rpfilter 2> /dev/null || true
    ip46tables -t mangle -X awos-fw-rpfilter 2> /dev/null || true

    ${lib.optionalString (kernelHasRPFilter && (cfg.checkReversePath != false)) ''
      # Perform a reverse-path test to refuse spoofers
      # For now, we just drop, as the mangle table doesn't have a log-refuse yet
      ip46tables -t mangle -N awos-fw-rpfilter 2> /dev/null || true
      ip46tables -t mangle -A awos-fw-rpfilter -m rpfilter --validmark ${
        lib.optionalString (cfg.checkReversePath == "loose") "--loose"
      } -j RETURN

      # Allows this host to act as a DHCP4 client without first having to use APIPA
      iptables -t mangle -A awos-fw-rpfilter -p udp --sport 67 --dport 68 -j RETURN

      # Allows this host to act as a DHCPv4 server
      iptables -t mangle -A awos-fw-rpfilter -s 0.0.0.0 -d 255.255.255.255 -p udp --sport 68 --dport 67 -j RETURN

      ${lib.optionalString cfg.logReversePathDrops ''
        ip46tables -t mangle -A awos-fw-rpfilter -j LOG --log-level info --log-prefix "rpfilter drop: "
      ''}
      ip46tables -t mangle -A awos-fw-rpfilter -j DROP

      ip46tables -t mangle -A PREROUTING -j awos-fw-rpfilter
    ''}

    # Accept all traffic on the trusted interfaces.
    ${lib.flip lib.concatMapStrings cfg.trustedInterfaces (iface: ''
      ip46tables -A awos-fw -i ${iface} -j awos-fw-accept
    '')}

    # Accept packets from established or related connections.
    ip46tables -A awos-fw -m conntrack --ctstate ESTABLISHED,RELATED -j awos-fw-accept

    # Accept connections to the allowed TCP ports.
    ${lib.concatStrings (
      lib.mapAttrsToList (
        iface: cfg:
        lib.concatMapStrings (port: ''
          ip46tables -A awos-fw -p tcp --dport ${toString port} -j awos-fw-accept ${
            lib.optionalString (iface != "default") "-i ${iface}"
          }
        '') cfg.allowedTCPPorts
      ) cfg.allInterfaces
    )}

    # Accept connections to the allowed TCP port ranges.
    ${lib.concatStrings (
      lib.mapAttrsToList (
        iface: cfg:
        lib.concatMapStrings (
          rangeAttr:
          let
            range = toString rangeAttr.from + ":" + toString rangeAttr.to;
          in
          ''
            ip46tables -A awos-fw -p tcp --dport ${range} -j awos-fw-accept ${
              lib.optionalString (iface != "default") "-i ${iface}"
            }
          ''
        ) cfg.allowedTCPPortRanges
      ) cfg.allInterfaces
    )}

    # Accept packets on the allowed UDP ports.
    ${lib.concatStrings (
      lib.mapAttrsToList (
        iface: cfg:
        lib.concatMapStrings (port: ''
          ip46tables -A awos-fw -p udp --dport ${toString port} -j awos-fw-accept ${
            lib.optionalString (iface != "default") "-i ${iface}"
          }
        '') cfg.allowedUDPPorts
      ) cfg.allInterfaces
    )}

    # Accept packets on the allowed UDP port ranges.
    ${lib.concatStrings (
      lib.mapAttrsToList (
        iface: cfg:
        lib.concatMapStrings (
          rangeAttr:
          let
            range = toString rangeAttr.from + ":" + toString rangeAttr.to;
          in
          ''
            ip46tables -A awos-fw -p udp --dport ${range} -j awos-fw-accept ${
              lib.optionalString (iface != "default") "-i ${iface}"
            }
          ''
        ) cfg.allowedUDPPortRanges
      ) cfg.allInterfaces
    )}

    # Optionally respond to ICMPv4 pings.
    ${lib.optionalString cfg.allowPing ''
      iptables -w -A awos-fw -p icmp --icmp-type echo-request ${
        lib.optionalString (cfg.pingLimit != null) "-m limit ${cfg.pingLimit} "
      }-j awos-fw-accept
    ''}

    ${lib.optionalString config.networking.enableIPv6 ''
      # Accept all ICMPv6 messages except redirects and node
      # information queries (type 139).  See RFC 4890, section
      # 4.4.
      ip6tables -A awos-fw -p icmpv6 --icmpv6-type redirect -j DROP
      ip6tables -A awos-fw -p icmpv6 --icmpv6-type 139 -j DROP
      ip6tables -A awos-fw -p icmpv6 -j awos-fw-accept

      # Allow this host to act as a DHCPv6 client
      ip6tables -A awos-fw -d fe80::/64 -p udp --dport 546 -j awos-fw-accept
    ''}

    ${cfg.extraCommands}

    # Reject/drop everything else.
    ip46tables -A awos-fw -j awos-fw-log-refuse


    # Enable the firewall.
    ip46tables -A INPUT -j awos-fw
  '';

  stopScript = writeShScript "firewall-stop" ''
    ${helpers}

    # Clean up in case reload fails
    ip46tables -D INPUT -j awos-drop 2>/dev/null || true

    # Clean up after added ruleset
    ip46tables -D INPUT -j awos-fw 2>/dev/null || true

    ${lib.optionalString (kernelHasRPFilter && (cfg.checkReversePath != false)) ''
      ip46tables -t mangle -D PREROUTING -j awos-fw-rpfilter 2>/dev/null || true
    ''}

    ${cfg.extraStopCommands}
  '';

  reloadScript = writeShScript "firewall-reload" ''
    ${helpers}

    # Create a unique drop rule
    ip46tables -D INPUT -j awos-drop 2>/dev/null || true
    ip46tables -F awos-drop 2>/dev/null || true
    ip46tables -X awos-drop 2>/dev/null || true
    ip46tables -N awos-drop
    ip46tables -A awos-drop -j DROP

    # Don't allow traffic to leak out until the script has completed
    ip46tables -A INPUT -j awos-drop

    ${cfg.extraStopCommands}

    if ${startScript}; then
      ip46tables -D INPUT -j awos-drop 2>/dev/null || true
    else
      echo "Failed to reload firewall... Stopping"
      ${stopScript}
      exit 1
    fi
  '';

in

{

  options = {

    networking.firewall = {
      extraCommands = lib.mkOption {
        type = lib.types.lines;
        default = "";
        example = "iptables -A INPUT -p icmp -j ACCEPT";
        description = ''
          Additional shell commands executed as part of the firewall
          initialisation script.  These are executed just before the
          final "reject" firewall rule is added, so they can be used
          to allow packets that would otherwise be refused.

          This option only works with the iptables based firewall.
        '';
      };

      extraStopCommands = lib.mkOption {
        type = lib.types.lines;
        default = "";
        example = "iptables -P INPUT ACCEPT";
        description = ''
          Additional shell commands executed as part of the firewall
          shutdown script.  These are executed just after the removal
          of the awos input rule, or if the service enters a failed
          state.

          This option only works with the iptables based firewall.
        '';
      };
    };

  };

  # FIXME: Maybe if `enable' is false, the firewall should still be
  # built but not started by default?
  config = lib.mkIf (cfg.enable && config.networking.nftables.enable == false) {

    assertions = [
      # This is approximately "checkReversePath -> kernelHasRPFilter",
      # but the checkReversePath option can include non-boolean
      # values.
      {
        assertion = cfg.checkReversePath == false || kernelHasRPFilter;
        message = "This kernel does not support rpfilter";
      }
    ];

    networking.firewall.checkReversePath = lib.mkIf (!kernelHasRPFilter) (lib.mkDefault false);

    systemd.services.firewall = {
      description = "Firewall";
      wantedBy = [ "sysinit.target" ];
      wants = [ "network-pre.target" ];
      after = [ "systemd-modules-load.service" ];
      before = [
        "network-pre.target"
        "shutdown.target"
      ];
      conflicts = [ "shutdown.target" ];

      path = [ cfg.package ] ++ cfg.extraPackages;

      # FIXME: this module may also try to load kernel modules, but
      # containers don't have CAP_SYS_MODULE.  So the host system had
      # better have all necessary modules already loaded.
      unitConfig.ConditionCapability = "CAP_NET_ADMIN";
      unitConfig.DefaultDependencies = false;

      reloadIfChanged = true;

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "@${startScript} firewall-start";
        ExecReload = "@${reloadScript} firewall-reload";
        ExecStop = "@${stopScript} firewall-stop";
      };
    };

  };

}
