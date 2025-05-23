{pkgs, ...}: {
  hardware = {
    sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
      disabledDefaultBackends = ["escl"];
    };
    logitech.wireless.enable = false;
    logitech.wireless.enableGraphical = false;
    graphics.enable = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;

    xpadneo.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        experimental = true; # show battery

        # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
        # for pairing bluetooth controller
        Privacy = "device";
        JustWorksRepairing = "always";
        Class = "0x000100";
        FastConnectable = true;
      };
    };
  };
}
