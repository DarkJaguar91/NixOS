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

    # zram swap is just compressed RAM, so swapping is ~free compared to
    # dropping page cache and re-reading from disk. Push anonymous memory to
    # zram aggressively (Fedora's zram default is 180). page-cluster and
    # watermark_boost_factor already land on their good zram values (0).
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
    };
  };
}
