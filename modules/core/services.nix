_: {
  services = {
    libinput.enable = true;
    fstrim.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    blueman.enable = true;
    tumbler.enable = true;
    flatpak.enable = true;

    smartd = {
      enable = true;
      autodetect = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
