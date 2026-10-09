{
  flake.modules.nixos.laptop =
    { lib, ... }:
    {
      services.auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            turbo = "auto";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };
      };

      # auto-cpufreq owns frequency scaling; noctalia's recommendedServices
      # would otherwise enable power-profiles-daemon by default
      services.power-profiles-daemon.enable = false;

      services.fwupd.enable = true;

      # Jovian sets this to "Ignore" because on a Deck the Steam UI shuts down
      # on low battery; nothing does that in the desktop session.
      services.upower.criticalPowerAction = lib.mkForce "PowerOff";
    };
}
