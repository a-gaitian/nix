{ pkgs, ... }: let

  home-manager = builtins.fetchGit {
    url = "git@github.com:nix-community/home-manager.git";
    ref = "release-25.05";
  };

  gmodules = builtins.fetchGit {
    url = "git@github.com:a-gaitian/gmodules.git";
    ref = "master";
  };
#  gmodules = ../.;
in {
  imports = [
    ./hardware.nix
    (import "${gmodules}/nixos")
    (import "${home-manager}/nixos")
  ];

  home-manager = {
    useGlobalPkgs = false;
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
    desktop = {
      theme.catppuccin.enable = true;
      hyprland = {
        enableFor = [ "user" ];
      };
    };
    utilities.enableAll = true;
  };

  system.stateVersion = "25.05";
}