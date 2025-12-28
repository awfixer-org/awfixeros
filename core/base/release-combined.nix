# This jobset defines the main awos channels (such as awos-unstable
# and awos-14.04). The channel is updated every time the ‘tested’ job
# succeeds, and all other jobs have finished (they may fail).

{
  nixpkgs ? {
    outPath = (import ../lib).cleanSource ./..;
    revCount = 56789;
    shortRev = "gfedcba";
  },
  stableBranch ? false,
  supportedSystems ? [
    "aarch64-linux"
    "x86_64-linux"
  ],
  limitedSupportedSystems ? [ ],
}:

let

  nixpkgsSrc = nixpkgs; # urgh

  pkgs = import ./.. { };

  removeMaintainers =
    set:
    if builtins.isAttrs set then
      if (set.type or "") == "derivation" then
        set // { meta = builtins.removeAttrs (set.meta or { }) [ "maintainers" ]; }
      else
        pkgs.lib.mapAttrs (n: v: removeMaintainers v) set
    else
      set;

in
rec {

  awos = removeMaintainers (
    import ./release.nix {
      inherit stableBranch;
      supportedSystems = supportedSystems ++ limitedSupportedSystems;
      nixpkgs = nixpkgsSrc;
    }
  );

  nixpkgs = builtins.removeAttrs (removeMaintainers (
    import ../pkgs/top-level/release.nix {
      inherit supportedSystems;
      nixpkgs = nixpkgsSrc;
    }
  )) [ "unstable" ];

  tested =
    let
      onFullSupported = x: map (system: "${x}.${system}") supportedSystems;
      onAllSupported = x: map (system: "${x}.${system}") (supportedSystems ++ limitedSupportedSystems);
      onSystems =
        systems: x:
        map (system: "${x}.${system}") (
          pkgs.lib.intersectLists systems (supportedSystems ++ limitedSupportedSystems)
        );
    in
    pkgs.releaseTools.aggregate {
      name = "awos-${awos.channel.version}";
      meta = {
        description = "Release-critical builds for the awos channel";
        maintainers = [ ];
      };
      constituents = pkgs.lib.concatLists [
        [ "awos.channel" ]
        (onFullSupported "awos.dummy")
        (onAllSupported "awos.iso_minimal")
        (onSystems [ "x86_64-linux" "aarch64-linux" ] "awos.amazonImage")
        (onFullSupported "awos.iso_graphical")
        (onFullSupported "awos.manual")
        (onSystems [ "aarch64-linux" ] "awos.sd_image")
        (onFullSupported "awos.tests.acme.http01-builtin")
        (onFullSupported "awos.tests.acme.dns01")
        (onSystems [ "x86_64-linux" ] "awos.tests.boot.biosCdrom")
        (onSystems [ "x86_64-linux" ] "awos.tests.boot.biosUsb")
        (onFullSupported "awos.tests.boot-stage1")
        (onFullSupported "awos.tests.boot.uefiCdrom")
        (onFullSupported "awos.tests.boot.uefiUsb")
        (onFullSupported "awos.tests.chromium")
        (onFullSupported "awos.tests.containers-imperative")
        (onFullSupported "awos.tests.containers-ip")
        (onSystems [ "x86_64-linux" ] "awos.tests.docker")
        (onFullSupported "awos.tests.env")

        # Way too many manual retries required on Hydra.
        #  Apparently it's hard to track down the cause.
        #  So let's depend just on the packages for now.
        #(onFullSupported "awos.tests.firefox-esr")
        #(onFullSupported "awos.tests.firefox")
        # Note: only -unwrapped variants have a Hydra job.
        (onFullSupported "nixpkgs.firefox-esr-unwrapped")
        (onFullSupported "nixpkgs.firefox-unwrapped")

        (onFullSupported "awos.tests.firewall")
        (onFullSupported "awos.tests.fontconfig-default-fonts")
        (onFullSupported "awos.tests.gitlab")
        (onFullSupported "awos.tests.gnome")
        (onFullSupported "awos.tests.gnome-xorg")
        (onSystems [ "x86_64-linux" ] "awos.tests.hibernate")
        (onFullSupported "awos.tests.i3wm")
        (onSystems [ "aarch64-linux" ] "awos.tests.installer.simpleUefiSystemdBoot")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.btrfsSimple")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.btrfsSubvolDefault")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.btrfsSubvolEscape")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.btrfsSubvols")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.luksroot")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.lvm")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.separateBootZfs")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.separateBootFat")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.separateBoot")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.simpleLabels")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.simpleProvided")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.simpleUefiSystemdBoot")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.simple")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.swraid")
        (onSystems [ "x86_64-linux" ] "awos.tests.installer.zfsroot")
        (onSystems [ "x86_64-linux" ] "awos.tests.awos-rebuild-specialisations")
        (onFullSupported "awos.tests.nix-misc.default")
        (onFullSupported "awos.tests.ipv6")
        (onFullSupported "awos.tests.keymap.azerty")
        (onFullSupported "awos.tests.keymap.colemak")
        (onFullSupported "awos.tests.keymap.dvorak")
        (onFullSupported "awos.tests.keymap.dvorak-programmer")
        (onFullSupported "awos.tests.keymap.neo")
        (onFullSupported "awos.tests.keymap.qwertz")
        (onFullSupported "awos.tests.latestKernel.login")
        (onFullSupported "awos.tests.lightdm")
        (onFullSupported "awos.tests.login")
        (onFullSupported "awos.tests.misc")
        (onFullSupported "awos.tests.mutableUsers")
        (onFullSupported "awos.tests.nat.firewall")
        (onFullSupported "awos.tests.nat.standalone")
        (onFullSupported "awos.tests.networking.scripted.bond")
        (onFullSupported "awos.tests.networking.scripted.bridge")
        (onFullSupported "awos.tests.networking.scripted.dhcpOneIf")
        (onFullSupported "awos.tests.networking.scripted.dhcpSimple")
        (onFullSupported "awos.tests.networking.scripted.link")
        (onFullSupported "awos.tests.networking.scripted.loopback")
        (onFullSupported "awos.tests.networking.scripted.macvlan")
        (onFullSupported "awos.tests.networking.scripted.privacy")
        (onFullSupported "awos.tests.networking.scripted.routes")
        (onFullSupported "awos.tests.networking.scripted.sit-fou")
        (onFullSupported "awos.tests.networking.scripted.static")
        (onFullSupported "awos.tests.networking.scripted.virtual")
        (onFullSupported "awos.tests.networking.scripted.vlan")
        (onFullSupported "awos.tests.networking.networkd.bond")
        (onFullSupported "awos.tests.networking.networkd.bridge")
        (onFullSupported "awos.tests.networking.networkd.dhcpOneIf")
        (onFullSupported "awos.tests.networking.networkd.dhcpSimple")
        (onFullSupported "awos.tests.networking.networkd.link")
        (onFullSupported "awos.tests.networking.networkd.loopback")
        # Fails nondeterministically (https://github.com/awos/nixpkgs/issues/96709)
        #(onFullSupported "awos.tests.networking.networkd.macvlan")
        (onFullSupported "awos.tests.networking.networkd.privacy")
        (onFullSupported "awos.tests.networking.networkd.routes")
        (onFullSupported "awos.tests.networking.networkd.sit-fou")
        (onFullSupported "awos.tests.networking.networkd.static")
        (onFullSupported "awos.tests.networking.networkd.virtual")
        (onFullSupported "awos.tests.networking.networkd.vlan")
        (onFullSupported "awos.tests.systemd-networkd-ipv6-prefix-delegation")
        (onFullSupported "awos.tests.nfs4.simple")
        (onSystems [ "x86_64-linux" ] "awos.tests.oci-containers.podman")
        (onFullSupported "awos.tests.openssh")
        (onFullSupported "awos.tests.initrd-network-ssh")
        (onFullSupported "awos.tests.pantheon")
        (onFullSupported "awos.tests.php.fpm")
        (onFullSupported "awos.tests.php.httpd")
        (onFullSupported "awos.tests.php.pcre")
        (onFullSupported "awos.tests.plasma6")
        (onSystems [ "x86_64-linux" ] "awos.tests.podman")
        (onFullSupported "awos.tests.predictable-interface-names.predictableNetworkd")
        (onFullSupported "awos.tests.predictable-interface-names.predictable")
        (onFullSupported "awos.tests.predictable-interface-names.unpredictableNetworkd")
        (onFullSupported "awos.tests.predictable-interface-names.unpredictable")
        (onFullSupported "awos.tests.printing-service")
        (onFullSupported "awos.tests.printing-socket")
        (onFullSupported "awos.tests.proxy")
        (onFullSupported "awos.tests.sddm.default")
        (onFullSupported "awos.tests.shadow")
        (onFullSupported "awos.tests.simple")
        (onFullSupported "awos.tests.sway")
        (onFullSupported "awos.tests.switchTest")
        (onFullSupported "awos.tests.udisks2")
        (onFullSupported "awos.tests.xfce")
        (onFullSupported "nixpkgs.emacs")
        (onFullSupported "nixpkgs.jdk")
        (onSystems [ "x86_64-linux" ] "nixpkgs.mesa_i686") # i686 sanity check + useful
        [
          "nixpkgs.tarball"
          "nixpkgs.release-checks"
        ]
      ];
    };
}
