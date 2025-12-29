[GitHub Actions]: https://github.com/awfixer-os/awfixeros-iso/actions

<div align="center">

AWFixerOS ISO

AWFixerOS is a NixOS based Linux distribution focused on beginner friendliness and ease of use. This repository contains the configuration used to build the AWFixerOS ISO files.

</div>

> [!CAUTION]
> This ISO and the related OS are not done yet - use at your own risk.

## Where to download?

Nightly builds can be found in this repositories [GitHub Actions]

## How to build

1) Clone this repository and navigate to the project directory
2) `nix build .#install-isoConfigurations.AWFixerOS`
3) The resulting ISO file will be linked in `result/iso/AWFixerOS-<version>.iso`
