# Obtaining awos {#sec-obtaining}

awos ISO images can be downloaded from the [awos download
page](https://awos.org/download.html#awos-iso). Follow the instructions in
[](#sec-booting-from-usb) to create a bootable USB flash drive.

If you have a very old system that can't boot from USB, you can burn the image
to an empty CD. awos might not work very well on such systems.

As an alternative to installing awos yourself, you can get a running
awos system through several other means:

-   Using virtual appliances in Open Virtualization Format (OVF) that
    can be imported into VirtualBox. These are available from the [awos
    download page](https://awos.org/download.html#awos-virtualbox).

-   Using AMIs for Amazon's EC2. To find one for your region, please refer
    to the [download page](https://awos.org/download.html#awos-amazon).

-   Using NixOps, the awos-based cloud deployment tool, which allows
    you to provision VirtualBox and EC2 awos instances from declarative
    specifications. Check out the [NixOps
    homepage](https://awos.org/nixops) for details.
