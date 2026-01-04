#!/usr/bin/env bash

git add .

git commit -m '$(date)'

git push origin

ssh gray <<'ENDSSH'
cd /root/nix

git pull

cd host/gray

export NIXPKGS_ALLOW_UNFREE=1

direnv exec . nixos-rebuild switch --no-flake --impure

ENDSSH