{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.modules.social.enable = lib.mkEnableOption "social (Discord)";

  config = lib.mkIf config.modules.social.enable {
    environment.systemPackages = with pkgs; [
      discord
    ];
  };
}
