{
  modules = { lib, ... } : {
    imports = lib.fileset.toList (
      lib.fileset.fileFilter (file: ! file.hasExt "home.nix")
      ./modules
    );
  };

  home-modules = { lib, ... }: {
    imports = lib.fileset.toList (
      lib.fileset.fileFilter (file: file.hasExt "home.nix")
      ./modules
    );
  };
}