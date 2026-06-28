{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.ai-tools;
in
{
  options.modules.kitty = {
    enable = mkEnableOption "AI Tools (Claude code)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      claude-code
    ];
  };
}
