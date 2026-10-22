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

      # switch the DAC to the stream's native rate instead of resampling
      # everything to 48k (most music is 44.1k)
      extraConfig.pipewire."10-sample-rates"."context.properties" = {
        "default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
        ];
      };
    };
  };
}
