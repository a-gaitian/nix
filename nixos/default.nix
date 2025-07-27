{ lib, config, ... }:
let
  glib = import ./glib.nix { inherit lib config; };
in {
  _module.args = { inherit glib; };
  imports = lib.fileset.toList ./modules;
}