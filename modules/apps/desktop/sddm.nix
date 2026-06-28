{ lib, config, ... }: {
  options.modules.desktop.sddm.enable = lib.mkEnableOption "SDDM";

  config = lib.mkIf config.modules.desktop.sddm.enable {
    services = {
      xserver = {
        enable = true;
        xkb.layout = "us";
      };
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
      };
    };
    security.rtkit.enable = true;
  };
}
