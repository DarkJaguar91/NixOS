{ lib, config, pkgs, ... }: {
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
          wayland = {
            enable = true;
            # The default weston greeter has broken cursor/touchpad input;
            # kwin was what Plasma set before it was removed from AsusZ13
            compositor = "kwin";
          };
          theme = "sddm-astronaut-theme";
          extraPackages = [ pkgs.kdePackages.qtmultimedia ];
        };
      };
    };

    environment.systemPackages = [ pkgs.sddm-astronaut ];

    security.rtkit.enable = true;
  };
}
