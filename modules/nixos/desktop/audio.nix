{
  flake.modules.nixos.desktop = {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true; # lets pipewire acquire realtime priority

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true; # 32-bit games
      };
      pulse.enable = true;
    };
  };
}
