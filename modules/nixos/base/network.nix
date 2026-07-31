{
  flake.modules.nixos.base = {
    networking.networkmanager.enable = true;

    # Set wifi regulatory domain (fixes "regulatory prevented using AP
    # config, downgraded" and degraded 6GHz links)
    boot.kernelParams = [ "cfg80211.ieee80211_regdom=CA" ];

    # Disable wifi powersaving (fixes latency spikes/jitter)
    networking.networkmanager.settings.connection."wifi.powersave" = 2;
  };
}
