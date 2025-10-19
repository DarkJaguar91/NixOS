{
  config,
  lib,
  pkgs,
  usr,
  nixConfigPath,
  ...
}:
with lib;
let
  cfg = config.dj.btop;
in
{
  options.dj.btop = {
    enable = mkEnableOption "btop Term";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      btop
    ];

    environment.etc."tmpfiles.d/home-${usr.login}-btop.conf".text = ''
      L+    /home/${usr.login}/.config/btop                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/btop
    '';
  };
}
