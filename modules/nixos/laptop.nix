{
  flake.modules.nixos.laptop = {
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
  };
}
