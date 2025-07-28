#!/bin/sh
nixos-rebuild build-vm \
  -I nixos-config=./configuration.nix \
  -I nixpkgs=channel:nixos-25.05 \
  -I virtualisation.cores=2 \
  -I virtualisation.memorySize=2048 \
  --no-flake \
  --show-trace