{ config, lib, ... }:

{
  options.modules.laptop.enable = lib.mkEnableOption "laptop power management";

  config = lib.mkIf config.modules.laptop.enable {
    services.auto-cpufreq.enable = true;
    services.auto-cpufreq.settings = {
      battery = {
        governor = "powersave";
        turbo = "auto";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };

    services.fwupd.enable = true;
    services.power-profiles-daemon.enable = false;
  };
}
