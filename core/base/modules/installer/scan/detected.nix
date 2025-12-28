# List all devices which are detected by awos-generate-config.
# Common devices are enabled by default.
{ lib, ... }:
{
  config = lib.mkDefault {
    # Common firmware, i.e. for wifi cards
    hardware.enableRedistributableFirmware = true;
  };
}
