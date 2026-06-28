{ lib, config, ... }: {
  options.modules.bluetooth.enable = lib.mkEnableOption "bluetooth";

  config = lib.mkIf config.modules.bluetooth.enable {
    hardware = {
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            Experimental = true;
          };
        };
      };
    };
  };
}
