{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    qmk
    via
    vial
  ];

  hardware.keyboard.qmk.enable = true;
  services.udev.packages = with pkgs; [
    via
    vial
  ];
}
