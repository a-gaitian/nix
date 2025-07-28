#!/bin/sh
nixos-rebuild build-vm \
  -I nixos-config=./configuration.nix \
  -I nixpkgs=channel:nixos-25.05 \
  --no-flake \
  --show-trace