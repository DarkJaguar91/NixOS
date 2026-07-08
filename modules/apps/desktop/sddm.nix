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
          wayland.enable = true;
          theme = "sddm-astronaut-theme";
          extraPackages = [ pkgs.kdePackages.qtmultimedia ];
        };
      };
    };

    environment.systemPackages = [ pkgs.sddm-astronaut ];

    security.rtkit.enable = true;
  };
}
