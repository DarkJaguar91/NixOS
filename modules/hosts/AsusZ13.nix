# ASUS ROG Flow Z13 (2025) — Ryzen AI Max "Strix Halo"
# Portable APU gaming tablet with MT7925 WiFi 7 and touchscreen.
{ inputs, ... }:
{
  flake.nixosModules."hosts/AsusZ13" =
    { pkgs, ... }:
    {
      imports = [
        # Base system stack: nix, git, nh, shell, neovim, network, fonts, sound, etc.
        inputs.self.nixosModules.base
        # Desktop: Noctalia ecosystem (Umbriel compositor + Noctalia shell + greeter)
        inputs.self.nixosModules.desktop
        # Gaming: Steam, gamescope, mangohud, 32-bit graphics
        inputs.self.nixosModules.gaming
        # AMD GPU: amdgpu initrd KMS, XWayland driver, OpenCL, 32-bit
        inputs.self.nixosModules."graphics/amd"

        # Generated hardware scan for this machine
        ../../hardware/AsusZ13-hardware.nix
      ];

      # ------------------------------------------------------------------
      # Identity
      # ------------------------------------------------------------------
      networking.hostName = "AsusZ13";

      # ------------------------------------------------------------------
      # Boot / Kernel
      # ------------------------------------------------------------------
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Strix Halo display/GPU quirks — prevent flicker and power issues
      boot.kernelParams = [
        "amdgpu.sg_display=0"
        "amdgpu.abmlevel=0"
        "amdgpu.dcdebugmask=0x600"
        "amdgpu.cwsr_enable=0"
        "iommu=pt"
      ];

      # Swap LUKS device is referenced in hardware-configuration.nix but not
      # unlocked at boot; add the initrd mapping here.
      boot.initrd.luks.devices."luks-8ff9e3ed-9e9f-4929-b3ac-face66162ada".device =
        "/dev/disk/by-uuid/8ff9e3ed-9e9f-4929-b3ac-face66162ada";

      # ------------------------------------------------------------------
      # Tablet / handheld-specific hardware
      # ------------------------------------------------------------------
      # Screen auto-rotation
      hardware.sensor.iio.enable = true;

      # Handheld Daemon — TDP / fan control and battery charge limit
      services.handheld-daemon = {
        enable = true;
        user = "brandon";
        adjustor.enable = true;
      };

      # ------------------------------------------------------------------
      # Packages
      # ------------------------------------------------------------------
      environment.systemPackages = with pkgs; [
        handheld-daemon-ui
        iw
        networkmanagerapplet
      ];

      # Stable symlink + user access for the touchscreen (used by lisgd gestures)
      services.udev.packages = [
        (pkgs.writeTextFile {
          name = "touchscreen-udev-rules";
          destination = "/etc/udev/rules.d/70-touchscreen.rules";
          text = ''
            SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="ELAN9008:00 04F3:43C7", SYMLINK+="input/touchscreen", TAG+="uaccess"
          '';
        })
      ];

      # ------------------------------------------------------------------
      # Memory / Swap
      # ------------------------------------------------------------------
      zramSwap.enable = true;

      # ------------------------------------------------------------------
      # State version
      # ------------------------------------------------------------------
      system.stateVersion = "26.05";
    };
}
