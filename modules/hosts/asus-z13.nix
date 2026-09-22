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
          asus-copilot-key
          asus-touchpad-precision-fix
          backlight
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
        { device = "/dev/disk/by-uuid/832168d0-ddbf-44c7-b1b2-363aaa448bcf";
          fsType = "ext4";
        };
    
      fileSystems."/boot" =
        { device = "/dev/disk/by-uuid/73C4-099C";
          fsType = "vfat";
          options = [ "fmask=0077" "dmask=0077" ];
        };
    
      swapDevices =
        [ { device = "/dev/disk/by-uuid/28cfb13e-e947-4cc0-af46-94734cd8c0f2"; }
        ];
    
      programs.gamemode.settings = {
        general = {
          softrealtime = "auto";
          renice = 10;
        };
        # Toggle APU GPU performance when entering / exiting a gamemode session.
        # Keeps battery life sane outside of games while giving the Strix Halo
        # full clocks when needed.
        custom = {
          start = "${pkgs.bash}/bin/bash -c 'for f in /sys/class/drm/card*/device/power_dpm_force_performance_level; do [ -w \"\\$f\" ] && echo high > \"\\$f\"; done'";
          end   = "${pkgs.bash}/bin/bash -c 'for f in /sys/class/drm/card*/device/power_dpm_force_performance_level; do [ -w \"\\$f\" ] && echo auto  > \"\\$f\"; done'";
        };
      };

      hardware.cpu.amd.updateMicrocode = true;
  
      system.stateVersion = "26.05";
    };
}
