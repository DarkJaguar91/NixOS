{pkgs, ...}: {
  hardware.nvidia = {
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Make sure to use the correct Bus ID values for your system!
      intelBusId = "${cfg.intelBusID}";
      nvidiaBusId = "${cfg.nvidiaBusID}";
    };
  };
}
