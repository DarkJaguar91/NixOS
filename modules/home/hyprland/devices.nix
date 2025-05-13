{host, ...}: let
  inherit
    (import ../../../hosts/${host}/variables.nix)
    extraDevicesSettings
    ;
in {
  wayland.windowManager.hyprland.settings = {
    device = [] ++ extraDevicesSettings;
  };
}
