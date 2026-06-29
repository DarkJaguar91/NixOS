{
  config,
  lib,
  pkgs,
  usr,
  nixConfigPath,
  ...
}:

{
  options.modules."3d-printing".enable = lib.mkEnableOption "3D printing apps";

  config = lib.mkIf config.modules."3d-printing".enable {
    environment.systemPackages = with pkgs; [
      orca-slicer
      freecad-wayland
    ];

    environment.etc."tmpfiles.d/home-${usr.login}-orca.conf".text = ''
      R  /home/${usr.login}/.config/OrcaSlicer - - - -
      L+ /home/${usr.login}/.config/OrcaSlicer - ${usr.login} - - ${nixConfigPath}/dots/orca-slicer
    '';
  };
}
