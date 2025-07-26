{ pkgs, ... }: {
  imports = [
    pkgs.lib.fileset.trace ./modules
  ];
}