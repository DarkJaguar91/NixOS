{
  flake.modules.nixos.laptop =
    { config, lib, ... }:
    {
      # Handheld Daemon owns CPU governor/EPP itself (per power profile, next
      # to TDP); auto-cpufreq fighting it pinned the governor to "performance",
      # which makes amd-pstate reject hhd's EPP writes (EINVAL) and burns the
      # shared APU power budget on the CPU instead of the iGPU.
      services.auto-cpufreq = lib.mkIf (!config.services.handheld-daemon.enable) {
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

      # Either auto-cpufreq or hhd owns power profiles (hhd emulates PPD's
      # D-Bus API); noctalia's recommendedServices would otherwise enable the
      # real power-profiles-daemon by default.
      services.power-profiles-daemon.enable = false;

      services.fwupd.enable = true;

      # Jovian sets this to "Ignore" because on a Deck the Steam UI shuts down
      # on low battery; nothing does that in the desktop session.
      services.upower.criticalPowerAction = lib.mkForce "PowerOff";
    };
}
