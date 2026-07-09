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
          # No cursor theme survived the Plasma removal, so the greeter's kwin
          # had nothing to render ("Unable to load any cursor theme")
          settings.Theme.CursorTheme = "breeze_cursors";
        };
      };
    };

    environment.systemPackages = [
      pkgs.sddm-astronaut
      pkgs.kdePackages.breeze # provides breeze_cursors for the greeter
    ];

    security.rtkit.enable = true;
  };
}
