# Provide an initial copy of the awos channel so that the user
# doesn't need to run "nix-channel --update" first.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  # This is copied into the installer image, so it's important that it is filtered
  # to avoid including a large .git directory.
  # We also want the source name to be normalised to "source" to avoid depending on the
  # location of nixpkgs.
  # In the future we might want to expose the ISO image from the flake and use
  # `self.outPath` directly instead.
  nixpkgs = lib.cleanSource pkgs.path;

  # We need a copy of the Nix expressions for Nixpkgs and awos on the
  # CD.  These are installed into the "awos" channel of the root
  # user, as expected by awos-rebuild/awos-install. FIXME: merge
  # with make-channel.nix.
  channelSources =
    pkgs.runCommand "awos-${config.system.awos.version}" { preferLocalBuild = true; }
      ''
        mkdir -p $out
        cp -prd ${nixpkgs.outPath} $out/awos
        chmod -R u+w $out/awos
        if [ ! -e $out/awos/nixpkgs ]; then
          ln -s . $out/awos/nixpkgs
        fi
        ${lib.optionalString (config.system.awos.revision != null) ''
          echo -n ${config.system.awos.revision} > $out/awos/.git-revision
        ''}
        echo -n ${config.system.awos.versionSuffix} > $out/awos/.version-suffix
        echo ${config.system.awos.versionSuffix} | sed -e s/pre// > $out/awos/svn-revision
      '';
in

{
  options.system.installer.channel.enable =
    (lib.mkEnableOption "bundling awos/Nixpkgs channel in the installer")
    // {
      default = true;
    };
  config = lib.mkIf config.system.installer.channel.enable {
    # Pin the nixpkgs flake in the installer to our cleaned up nixpkgs source.
    # FIXME: this might be surprising and is really only needed for offline installations,
    # see discussion in https://github.com/awos/nixpkgs/pull/204178#issuecomment-1336289021
    nix.registry.nixpkgs.to = {
      type = "path";
      path = "${channelSources}/awos";
    };

    # Provide the awos/Nixpkgs sources in /etc/awos.  This is required
    # for awos-install.
    boot.postBootCommands = lib.mkAfter ''
      if ! [ -e /var/lib/awos/did-channel-init ]; then
        echo "unpacking the awos/Nixpkgs sources..."
        mkdir -p /nix/var/nix/profiles/per-user/root
        ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/per-user/root/channels \
          -i ${channelSources} --quiet --option build-use-substitutes false \
          ${lib.optionalString config.boot.initrd.systemd.enable "--option sandbox false"} # There's an issue with pivot_root
        mkdir -m 0700 -p /root/.nix-defexpr
        ln -s /nix/var/nix/profiles/per-user/root/channels /root/.nix-defexpr/channels
        mkdir -m 0755 -p /var/lib/awos
        touch /var/lib/awos/did-channel-init
      fi
    '';
  };
}
