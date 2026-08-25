# ASUS ROG Flow Z13 (2025), Ryzen AI Max "Strix Halo". LUKS + btrfs
# (disko-managed; was mistakenly installed ext4 before).
{ config, ... }:
{
  flake.modules.nixos."hosts/AsusZ13" =
    { pkgs, modulesPath, ... }:
    {
      imports =
        (with config.flake.modules.nixos; [
          base
          desktop
          gaming
          printing
          laptop
          amd
          netbird
        ])
        ++ [ (modulesPath + "/installer/scan/not-detected.nix") ];

      networking.hostName = "AsusZ13";
      nixpkgs.hostPlatform = "x86_64-linux";

      # Strix Halo: 16C/32T but a single memory-bound APU. 8 parallel
      # derivations keeps the machine responsive during rebuilds.
      local.build.maxJobs = 8;

      # Strix Halo display/GPU quirks
      boot.kernelParams = [
        "amdgpu.sg_display=0"
        "amdgpu.abmlevel=0"
        "amdgpu.dcdebugmask=0x600"
        "amdgpu.cwsr_enable=0"
        "iommu=pt"
      ];

      # screen auto-rotation
      hardware.sensor.iio.enable = true;

      # TDP / fan control for the Strix Halo APU. Also owns the battery charge
      # limit (hhd-ui -> Battery Settings), which writes BAT0's
      # charge_control_end_threshold.
      services.handheld-daemon = {
        enable = true;
        user = "brandon";
        adjustor.enable = true;
      };
      environment.systemPackages = [ pkgs.handheld-daemon-ui ];

      # Hardware config
      boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sdhci_pci" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];
    
      fileSystems."/" =
        { device = "/dev/mapper/luks-431315d8-db32-42b3-abf2-2f89d170501d";
          fsType = "ext4";
        };
    
      boot.initrd.luks.devices."luks-431315d8-db32-42b3-abf2-2f89d170501d".device = "/dev/disk/by-uuid/431315d8-db32-42b3-abf2-2f89d170501d";
      boot.initrd.luks.devices."luks-8ff9e3ed-9e9f-4929-b3ac-face66162ada".device = "/dev/disk/by-uuid/8ff9e3ed-9e9f-4929-b3ac-face66162ada";
    
      fileSystems."/boot" =
        { device = "/dev/disk/by-uuid/0CE9-38D9";
          fsType = "vfat";
          options = [ "fmask=0077" "dmask=0077" ];
        };
    
      swapDevices =
        [ { device = "/dev/mapper/luks-8ff9e3ed-9e9f-4929-b3ac-face66162ada"; }
        ];
    
      hardware.cpu.amd.updateMicrocode = true;
  
      system.stateVersion = "26.05";
    };
}
