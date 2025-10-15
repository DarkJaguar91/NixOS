{ usr, ... }:
{
  services = {
    lact.enable = true;
    handheld-daemon = {
      enable = true;
      user = usr.login;
    };
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

  hardware.sensor.iio.enable = true;
  services.udev.extraRules = ''
    # Disable power auto-suspend for the ASUS N-KEY device, i.e. USB Keyboard.
    # Otherwise on certain kernel-versions, it will tend to take 1-2 key-presses to wake-up after the device suspends.
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{idVendor}=="0b05", ATTR{idProduct}=="19b6", ATTR{power/autosuspend}="-1"
  '';
}
