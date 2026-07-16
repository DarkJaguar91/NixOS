{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      services.xserver = {
        enable = true;
        xkb.layout = "us";
      };

      services.displayManager.sddm = {
        enable = true;
        wayland = {
          enable = true;
          # the default weston greeter has broken cursor/touchpad input
          compositor = "kwin";
        };
        theme = "sddm-astronaut-theme";
        extraPackages = [ pkgs.kdePackages.qtmultimedia ];
        # without an explicit cursor theme the kwin greeter has nothing to
        # render ("Unable to load any cursor theme")
        settings.Theme.CursorTheme = "breeze_cursors";
      };

      environment.systemPackages = [
        pkgs.sddm-astronaut
        pkgs.kdePackages.breeze # provides breeze_cursors for the greeter
      ];
    };
}
