{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.modules.mangowc.enable = lib.mkEnableOption "MangoWC Wayland compositor with Noctalia shell";

  config = lib.mkIf config.modules.mangowc.enable {
    programs.mangowc.enable = true;

    environment.systemPackages = with pkgs; [
      noctalia-shell
      noctalia-qs
    ];
  };
}
