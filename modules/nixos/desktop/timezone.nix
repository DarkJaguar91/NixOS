# Timezone from network location (geoclue), desktop machines only — the
# server pins a static time.timeZone instead.
{
  flake.modules.nixos.desktop = {
    services.automatic-timezoned.enable = true;
  };
}
