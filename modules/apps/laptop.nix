{ config, lib, ... }:
{
  options.modules.laptop.enable = lib.mkEnableOption "laptop power management";

  config = lib.mkIf config.modules.laptop.enable {
    services = {
      auto-cpufreq = {
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
      fwupd.enable = true;
      power-profiles-daemon.enable = false;
    };
  };
}
