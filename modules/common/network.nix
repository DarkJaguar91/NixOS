{ config, pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    # Reverted to wpa_supplicant: iwd had issues with 6 GHz CA regulatory on MT7925.
    # wifi.backend = "iwd";
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    iw
  ];
}
