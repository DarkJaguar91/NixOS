{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.modules.media.enable = lib.mkEnableOption "Media Apps (Spotiyfy, Discord, ...)";

  config = lib.mkIf config.modules.media.enable {
    environment.systemPackages = with pkgs; [
      brave
      spotify
      discord
    ];
  };
}
