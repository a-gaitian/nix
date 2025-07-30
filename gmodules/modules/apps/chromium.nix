{ pkgs, config, lib, glib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf length;
  user = config.gmodules.home.user;
  cfg = config.gmodules.app.chromium;
in {
  options.gmodules.app.chromium = {
    enable = mkEnableOption "chromium";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (ungoogled-chromium.override {
        commandLineArgs = "--enable-features=" + lib.foldl
          (feature: list: list+","+feature)
          ""
          [
            "VaapiVideoDecodeLinuxGL"
            "VaapiVideoEncoder"
            "Vulkan"
            "VulkanFromANGLE"
            "DefaultANGLEVulkan"
            "VaapiIgnoreDriverChecks"
            "VaapiVideoDecoder"
            "PlatformHEVCDecoderSupport"
            "UseMultiPlaneFormatForHardwareVideo"
          ];
      })
    ];
  };
}