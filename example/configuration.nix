{ pkgs, ... }: let

  home-manager = builtins.fetchGit {
    url = "git@github.com:nix-community/home-manager.git";
    ref = "release-25.05";
  };

  catppuccin = builtins.fetchGit {
    url = "git@github.com:catppuccin/nix.git";
  };

  gaitian-nix = builtins.fetchGit {
    url = "git@github.com:a-gaitian/nix.git";
  };
#  gaitian-nix = ../.;
in {
  imports = [
    ./hardware.nix
    (import "${home-manager}/nixos")
    (import "${catppuccin}/modules/nixos")
    (import "${gaitian-nix}/gmodules")
    (import "${gaitian-nix}/gmodules/theme/catppuccin.nix")
  ];

  home-manager = {
    useGlobalPkgs = false;
    users = {
      user = { pkgs, ... }: {
        home.stateVersion = "25.05";
        imports = [
          (import "${catppuccin}/modules/home-manager")
        ];
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
      hyprland = {
        enableFor = [ "user" ];
      };
    };
    utilities.enableAll = true;
  };

  system.stateVersion = "25.05";
}