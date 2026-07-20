# Seerr media request manager.
{
  flake.modules.nixos.server = {
    # runs as a DynamicUser with state in /var/lib/seerr — small sqlite db,
    # fine on the root disk (custom dirs fight the sandbox, see prowlarr)
    services.seerr = {
      enable = true;
      openFirewall = true; # 5055
    };
  };
}
