{ lib, config }: rec {

  users =
    builtins.map
      (user: user.name )
      (
        builtins.filter
          (user: user.value.isNormalUser)
          (lib.attrsToList config.users.users)
      );

  types = {
    listOfUsers = lib.types.listOf (
      lib.types.enum (users)
    );
  };

  mkEnableForOption = moduleName: lib.mkOption {
    type = types.listOfUsers;
    description = "Users for whom the ${moduleName} module will be enabled";
    default = [ ];
    example = [ "user" ];
  };

  usersConfig = users: configFunc:
    builtins.listToAttrs (
      map (
        user: { name = user; value = configFunc user; }
      ) users
    );

  usersConfigOrDefault = isDefault: usersArg: configFunc:
    usersConfig
      (if isDefault then users else usersArg)
      configFunc;
}