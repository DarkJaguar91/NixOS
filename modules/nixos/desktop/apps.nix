{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        brave
        discord
        spotify
      ];

      # chromium/electron apps (all three above) run native wayland
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };
}
