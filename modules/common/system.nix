{ config, pkgs, ... }:

{
  time.timeZone = null;

  services.timesyncd.enable = true;
  services.automatic-timezoned.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # Run unpatched dynamically-linked binaries (game launchers, dev tools, etc.)
  programs.nix-ld.enable = true;

  # Required for WiFi firmware and the wireless regulatory database.
  # Without this, WiFi 7/6GHz bands are severely restricted.
  hardware.enableRedistributableFirmware = true;
}
