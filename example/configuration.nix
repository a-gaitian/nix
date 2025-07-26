{ pkgs, ... }: let
  gmodules = builtins.fetchGit {
    url = "git@github.com:a-gaitian/gmodules.git";
    ref = "master";
  };
in {

  imports = [
    ./hardware.nix
    gmodules
  ];

  users.users = {
    user = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "password";
    };
  };

  # NEVER changes
  system.stateVersion = "25.05";
}