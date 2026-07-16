{
  flake.modules.nixos.base = {
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    zramSwap.enable = true;
  };
}
