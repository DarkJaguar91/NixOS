{ ... }: {
  hardware = {
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    enableAllFirmware = true;
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
}
