{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      hardware.enableRedistributableFirmware = true;

      services.fstrim.enable = true;
      services.smartd = {
        enable = true;
        autodetect = true;
      };

      environment.systemPackages = with pkgs; [
        htop
        wget
        psmisc # killall
      ];
    };
}
