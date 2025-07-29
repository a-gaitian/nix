{ lib, config }: rec {

  mkEnableOption = default: name: lib.mkOption {
    type = lib.types.bool;
    description = "Is ${name} enabled?";
    inherit default;
    example = !default;
  };
}