{
  flake.modules.nixos.gaming = {
    # proper Xbox controller support over bluetooth (rumble, battery, mapping)
    hardware.xpadneo.enable = true;
    # PlayStation/Switch controllers work out of the box via steam-hardware
    # udev rules, which programs.steam already enables
  };
}
