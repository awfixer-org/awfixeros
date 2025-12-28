{ modulesPath, ... }:

{
  # To build the configuration or use nix-env, you need to run
  # either awos-rebuild --upgrade or nix-channel --update
  # to fetch the awos channel.

  # This configures everything but bootstrap services,
  # which only need to be run once and have already finished
  # if you are able to see this comment.
  imports = [
    "${modulesPath}/virtualisation/azure-common.nix"
    "${modulesPath}/virtualisation/azure-image.nix"
  ];

  # Please set the VM Generation to the actual value
  # virtualisation.azureImage.vmGeneration = "v1";
}
