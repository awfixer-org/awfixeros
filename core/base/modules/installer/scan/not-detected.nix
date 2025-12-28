# Enables non-free firmware on devices not recognized by `awos-generate-config`.
{ lib, ... }:

{
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
