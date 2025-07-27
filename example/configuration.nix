{ config, pkgs, ... }: let

  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;

#  gmodules = builtins.fetchGit {
#    url = "https://github.com/a-gaitian/gmodules.git";
#    rev = "1058f07761c577e7bb9e6484051afca55770633e";
#  };
  gmodules = import ../default.nix;
in {
  imports = [
    ./hardware.nix
    gmodules.modules
    (import "${home-manager}/nixos")
  ];

  gmodules = {
    shell.fish.enable = true;
  };

  home-manager.users.user = { pkgs, ... }: {
    home.stateVersion = "25.05";
    imports = [ gmodules.home-modules ];
    gmodules = {
      home.shell.fish.enable = true;
    };
  };

  users.users = {
    user = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialPassword = "pass";
    };
  };

  # NEVER changes
  system.stateVersion = "25.05";
}