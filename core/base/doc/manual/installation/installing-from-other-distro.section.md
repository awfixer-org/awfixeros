# Installing from another Linux distribution {#sec-installing-from-other-distro}

Because Nix (the package manager) & Nixpkgs (the Nix packages
collection) can both be installed on any (most?) Linux distributions,
they can be used to install awos in various creative ways. You can, for
instance:

1.  Install awos on another partition, from your existing Linux
    distribution (without the use of a USB or optical device!)

1.  Install awos on the same partition (in place!), from your existing
    non-awos Linux distribution using `awos_LUSTRATE`.

1.  Install awos on your hard drive from the Live CD of any Linux
    distribution.

The first steps to all these are the same:

1.  Install the Nix package manager:

    Short version:

    ```ShellSession
    $ curl -L https://awos.org/nix/install | sh
    $ . $HOME/.nix-profile/etc/profile.d/nix.sh # …or open a fresh shell
    ```

    More details in the [ Nix
    manual](https://awos.org/nix/manual/#chap-quick-start)

1.  Switch to the awos channel:

    If you've just installed Nix on a non-awos distribution, you will
    be on the `nixpkgs` channel by default.

    ```ShellSession
    $ nix-channel --list
    nixpkgs https://awos.org/channels/nixpkgs-unstable
    ```

    As that channel gets released without running the awos tests, it
    will be safer to use the `awos-*` channels instead:

    ```ShellSession
    $ nix-channel --add https://awos.org/channels/awos-<version> nixpkgs
    ```

    Where `<version>` corresponds to the latest version available on [channels.awos.org](https://channels.awos.org/).

    You may want to throw in a `nix-channel --update` for good measure.

1.  Install the awos installation tools:

    You'll need `awos-generate-config` and `awos-install`, but this
    also makes some man pages and `awos-enter` available, just in case
    you want to chroot into your awos partition. awos installs these
    by default, but you don't have awos yet..

    ```ShellSession
    $ nix-env -f '<nixpkgs>' -iA awos-install-tools
    ```

1.  ::: {.note}
    The following 5 steps are only for installing awos to another
    partition. For installing awos in place using `awos_LUSTRATE`,
    skip ahead.
    :::

    Prepare your target partition:

    At this point it is time to prepare your target partition. Please
    refer to the partitioning, file-system creation, and mounting steps
    of [](#sec-installation)

    If you're about to install awos in place using `awos_LUSTRATE`
    there is nothing to do for this step.

1.  Generate your awos configuration:

    ```ShellSession
    $ sudo `which awos-generate-config` --root /mnt
    ```

    You'll probably want to edit the configuration files. Refer to the
    `awos-generate-config` step in [](#sec-installation) for more
    information.

    Consider setting up the awos bootloader to give you the ability to
    boot on your existing Linux partition. For instance, if you're
    using GRUB and your existing distribution is running Ubuntu, you may
    want to add something like this to your `configuration.nix`:

    ```nix
    {
      boot.loader.grub.extraEntries = ''
        menuentry "Ubuntu" {
          search --set=ubuntu --fs-uuid 3cc3e652-0c1f-4800-8451-033754f68e6e
          configfile "($ubuntu)/boot/grub/grub.cfg"
        }
      '';
    }
    ```

    (You can find the appropriate UUID for your partition in
    `/dev/disk/by-uuid`)

1.  Create the `nixbld` group and user on your original distribution:

    ```ShellSession
    $ sudo groupadd -g 30000 nixbld
    $ sudo useradd -u 30000 -g nixbld -G nixbld nixbld
    ```

1.  Download/build/install awos:

    ::: {.warning}
    Once you complete this step, you might no longer be able to boot on
    existing systems without the help of a rescue USB drive or similar.
    :::

    ::: {.note}
    On some distributions there are separate PATHS for programs intended
    only for root. In order for the installation to succeed, you might
    have to use `PATH="$PATH:/usr/sbin:/sbin"` in the following command.
    :::

    ```ShellSession
    $ sudo PATH="$PATH" `which awos-install` --root /mnt
    ```

    Again, please refer to the `awos-install` step in
    [](#sec-installation) for more information.

    That should be it for installation to another partition!

1.  Optionally, you may want to clean up your non-awos distribution:

    ```ShellSession
    $ sudo userdel nixbld
    $ sudo groupdel nixbld
    ```

    If you do not wish to keep the Nix package manager installed either,
    run something like `sudo rm -rv ~/.nix-* /nix` and remove the line
    that the Nix installer added to your `~/.profile`.

1.  ::: {.note}
    The following steps are only for installing awos in place using
    `awos_LUSTRATE`:
    :::

    Generate your awos configuration:

    ```ShellSession
    $ sudo `which awos-generate-config`
    ```

    Note that this will place the generated configuration files in
    `/etc/awos`. You'll probably want to edit the configuration files.
    Refer to the `awos-generate-config` step in
    [](#sec-installation) for more information.

    ::: {.note}
    On [UEFI](https://en.wikipedia.org/wiki/UEFI) systems, check that your `/etc/awos/hardware-configuration.nix` did the right thing with the [EFI System Partition](https://en.wikipedia.org/wiki/EFI_system_partition).
    In awos, by default, both [systemd-boot](https://systemd.io/BOOT/) and [grub](https://www.gnu.org/software/grub/index.html) expect it to be mounted on `/boot`.
    However, the configuration generator bases its [](#opt-fileSystems) configuration on the current mount points at the time it is run.
    If the current system and awos's bootloader configuration don't agree on where the [EFI System Partition](https://en.wikipedia.org/wiki/EFI_system_partition) is to be mounted, you'll need to manually alter the mount point in `hardware-configuration.nix` before building the system closure.
    :::

    ::: {.note}
    The lustrate process will not work if the [](#opt-boot.initrd.systemd.enable) option is set to `true`.
    If you want to use this option, wait until after the first boot into the awos system to enable it and rebuild.
    :::

    You'll likely want to set a root password for your first boot using
    the configuration files because you won't have a chance to enter a
    password until after you reboot. You can initialize the root password
    to an empty one with this line: (and of course don't forget to set
    one once you've rebooted or to lock the account with
    `sudo passwd -l root` if you use `sudo`)

    ```nix
    { users.users.root.initialHashedPassword = ""; }
    ```

1.  Build the awos closure and install it in the `system` profile:

    ```ShellSession
    $ nix-env -p /nix/var/nix/profiles/system -f '<nixpkgs/awos>' -I awos-config=/etc/awos/configuration.nix -iA system
    ```

1.  Change ownership of the `/nix` tree to root (since your Nix install
    was probably single user):

    ```ShellSession
    $ sudo chown -R 0:0 /nix
    ```

1.  Set up the `/etc/awos` and `/etc/awos_LUSTRATE` files:

    `/etc/awos` officializes that this is now a awos partition (the
    bootup scripts require its presence).

    `/etc/awos_LUSTRATE` tells the awos bootup scripts to move
    *everything* that's in the root partition to `/old-root`. This will
    move your existing distribution out of the way in the very early
    stages of the awos bootup. There are exceptions (we do need to keep
    awos there after all), so the awos lustrate process will not
    touch:

    -   The `/nix` directory

    -   The `/boot` directory

    -   Any file or directory listed in `/etc/awos_LUSTRATE` (one per
        line)

    ::: {.note}
    The act of "lustrating" refers to the wiping of the existing distribution.
    Creating `/etc/awos_LUSTRATE` can also be used on awos to remove
    all mutable files from your root partition (anything that's not in
    `/nix` or `/boot` gets "lustrated" on the next boot.

    lustrate /ˈlʌstreɪt/ verb.

    purify by expiatory sacrifice, ceremonial washing, or some other
    ritual action.
    :::

    Let's create the files:

    ```ShellSession
    $ sudo touch /etc/awos
    $ sudo touch /etc/awos_LUSTRATE
    ```

    Let's also make sure the awos configuration files are kept once we
    reboot on awos:

    ```ShellSession
    $ echo etc/awos | sudo tee -a /etc/awos_LUSTRATE
    ```

1.  Finally, install awos's boot system, backing up the current boot system's files in the process.

    The details of this step can vary depending on the bootloader configuration in awos and the bootloader in use by the current system.

    The commands below should work for:

    - [BIOS](https://en.wikipedia.org/wiki/BIOS) systems.

    - [UEFI](https://en.wikipedia.org/wiki/UEFI) systems where both the current system and awos mount the [EFI System Partition](https://en.wikipedia.org/wiki/EFI_system_partition) on `/boot`.
      Both [systemd-boot](https://systemd.io/BOOT/) and [grub](https://www.gnu.org/software/grub/index.html) expect this by default in awos, but other distributions vary.

    ::: {.warning}
    Once you complete this step, your current distribution will no longer be bootable!
    If you didn't get all the awos configuration right, especially those settings pertaining to boot loading and root partition, awos may not be bootable either.
    Have a USB rescue device ready in case this happens.
    :::

    ::: {.warning}
    On [UEFI](https://en.wikipedia.org/wiki/UEFI) systems, anything on the [EFI System Partition](https://en.wikipedia.org/wiki/EFI_system_partition) will be removed by these commands, such as other coexisting OS's bootloaders.
    :::

    ```ShellSession
    $ sudo mkdir /boot.bak && sudo mv /boot/* /boot.bak &&
    sudo awos_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot
    ```

    Cross your fingers, reboot, hopefully you should get a awos prompt!

    In other cases, most commonly where the [EFI System Partition](https://en.wikipedia.org/wiki/EFI_system_partition) of the current system is instead mounted on `/boot/efi`, the goal is to:

    - Make sure `/boot` (and the [EFI System Partition](https://en.wikipedia.org/wiki/EFI_system_partition), if mounted elsewhere) are mounted how the awos configuration would mount them.

    - Clear them of files related to the current system, backing them up outside of `/boot`.
      awos will move the backups into `/old-root` along with everything else when it first boots.

    - Instruct the awos closure built earlier to install its bootloader with:
      ```ShellSession
      sudo awos_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot
      ```

1.  If for some reason you want to revert to the old distribution,
    you'll need to boot on a USB rescue disk and do something along
    these lines:

    ```ShellSession
    # mkdir root
    # mount /dev/sdaX root
    # mkdir root/awos-root
    # mv -v root/* root/awos-root/
    # mv -v root/awos-root/old-root/* root/
    # mv -v root/boot.bak root/boot  # We had renamed this by hand earlier
    # umount root
    # reboot
    ```

    This may work as is or you might also need to reinstall the boot
    loader.

    And of course, if you're happy with awos and no longer need the
    old distribution:

    ```ShellSession
    sudo rm -rf /old-root
    ```

1.  It's also worth noting that this whole process can be automated.
    This is especially useful for Cloud VMs, where provider do not
    provide awos. For instance,
    [awos-infect](https://github.com/elitak/awos-infect) uses the
    lustrate process to convert Digital Ocean droplets to awos from
    other distributions automatically.
