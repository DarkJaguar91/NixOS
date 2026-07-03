{ lib, config, ... }:
{
  options.modules.seerr.enable = lib.mkEnableOption "Seerr media request manager";

  config = lib.mkIf config.modules.seerr.enable {
    # runs as a DynamicUser with state in /var/lib/seerr — small sqlite db,
    # fine on the root disk (custom dirs fight the sandbox, see prowlarr)
    services.seerr = {
      enable = true;
      openFirewall = true; # 5055
    };
  };
}
