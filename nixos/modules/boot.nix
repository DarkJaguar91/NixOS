{ pkgs, ... }: {
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    plymouth.enable = true;

    # EFI Boot
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
}
