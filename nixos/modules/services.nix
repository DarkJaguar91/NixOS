{ ... }: {
  services = {
    tumbler.enable = true; # Icon based DBus toolkit
    smartd = { # Standard smart drive tooling
      enable = false;
      autodetect = true;
    };
    fstrim = { # Filesystem trim
      enable = true;
      interval = "weekly";
    };
    libinput.enable = true; # Input service - helps with some HIDs
    blueman.enable = true; # Bluetooth manager :)
    upower.enable = true; # Powertoolkit obvs
    openssh.enable = true;
  };
  powerManagement = {
    enable = true;
	  cpuFreqGovernor = "schedutil";
  };
}
