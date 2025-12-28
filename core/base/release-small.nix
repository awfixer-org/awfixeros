# This jobset is used to generate a awos channel that contains a
# small subset of Nixpkgs, mostly useful for servers that need fast
# security updates.
#
# Individual jobs can be tested by running:
#
#   nix-build awos/release-small.nix -A <jobname>
#
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
  ], # no i686-linux
}:

let

  nixpkgsSrc = nixpkgs; # urgh

  pkgs = import ./.. { system = "x86_64-linux"; };

  lib = pkgs.lib;

  awos' = import ./release.nix {
    inherit stableBranch supportedSystems;
    nixpkgs = nixpkgsSrc;
  };

  nixpkgs' = builtins.removeAttrs (import ../pkgs/top-level/release.nix {
    inherit supportedSystems;
    nixpkgs = nixpkgsSrc;
  }) [ "unstable" ];

in
rec {

  awos = {
    inherit (awos')
      channel
      manual
      options
      dummy
      ;
    tests = {
      acme = {
        inherit (awos'.tests.acme)
          http01-builtin
          dns01
          ;
      };
      inherit (awos'.tests)
        containers-imperative
        containers-ip
        firewall
        ipv6
        login
        misc
        nat
        nfs4
        openssh
        php
        predictable-interface-names
        proxy
        simple
        ;
      latestKernel = {
        inherit (awos'.tests.latestKernel)
          login
          ;
      };
      installer = {
        inherit (awos'.tests.installer)
          lvm
          separateBoot
          simple
          simpleUefiSystemdBoot
          ;
      };
    };
  };

  nixpkgs = {
    inherit (nixpkgs')
      apacheHttpd
      cmake
      cryptsetup
      emacs
      gettext
      git
      imagemagick
      jdk
      linux
      mariadb
      nginx
      nodejs
      openssh
      opensshTest
      php
      postgresql
      python3
      release-checks
      rsyslog
      stdenv
      subversion
      tarball
      vim
      tests-stdenv-gcc-stageCompare
      ;
  };

  tested =
    let
      onSupported = x: map (system: "${x}.${system}") supportedSystems;
      onSystems =
        systems: x: map (system: "${x}.${system}") (pkgs.lib.intersectLists systems supportedSystems);
    in
    pkgs.releaseTools.aggregate {
      name = "awos-${awos.channel.version}";
      meta = {
        description = "Release-critical builds for the awos channel";
        maintainers = [ ];
      };
      constituents = lib.flatten [
        [
          "awos.channel"
          "nixpkgs.tarball"
          "nixpkgs.release-checks"
        ]
        (map (onSystems [ "x86_64-linux" ]) [
          "awos.tests.installer.lvm"
          "awos.tests.installer.separateBoot"
          "awos.tests.installer.simple"
        ])
        (map onSupported [
          "awos.dummy"
          "awos.manual"
          "awos.tests.acme.http01-builtin"
          "awos.tests.acme.dns01"
          "awos.tests.containers-imperative"
          "awos.tests.containers-ip"
          "awos.tests.firewall"
          "awos.tests.ipv6"
          "awos.tests.installer.simpleUefiSystemdBoot"
          "awos.tests.login"
          "awos.tests.latestKernel.login"
          "awos.tests.misc"
          "awos.tests.nat.firewall"
          "awos.tests.nat.standalone"
          "awos.tests.nfs4.simple"
          "awos.tests.openssh"
          "awos.tests.php.fpm"
          "awos.tests.php.pcre"
          "awos.tests.predictable-interface-names.predictable"
          "awos.tests.predictable-interface-names.predictableNetworkd"
          "awos.tests.predictable-interface-names.unpredictable"
          "awos.tests.predictable-interface-names.unpredictableNetworkd"
          "awos.tests.proxy"
          "awos.tests.simple"
          "nixpkgs.jdk"
          "nixpkgs.tests-stdenv-gcc-stageCompare"
          "nixpkgs.opensshTest"
        ])
      ];
    };

}
