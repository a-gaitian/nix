{ pkgs, ... }: let

  home-manager = builtins.fetchGit {
    url = "git@github.com:nix-community/home-manager.git";
    ref = "release-25.05";
  };

  gmodules = builtins.fetchGit {
    url = "https://github.com/a-gaitian/gmodules.git";
    ref = "master";
  };
#  gmodules = ../default.nix;
in {
  imports = [
    ./hardware.nix
    gmodules
    (import "${home-manager}/nixos")
  ];

  home-manager = {
    useGlobalPkgs = true;
    users = {
      user = { pkgs, ... }: {
        home.stateVersion = "25.05";
      };
    };
  };

  users.users = {
    user = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "pass";
      shell = pkgs.fish;
    };
  };


  gmodules = {
    shell.fish.enableFor = [ "user" ];
  };

  system.stateVersion = "25.05";
}