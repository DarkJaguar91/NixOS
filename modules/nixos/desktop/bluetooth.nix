{
  flake.modules.nixos.desktop = {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Enable = "Source,Sink,Media,Socket";
        # battery reporting for controllers/headphones over BT
        Experimental = true;
      };
    };
  };
}
