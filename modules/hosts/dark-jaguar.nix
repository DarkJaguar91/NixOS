# Desktop: Ryzen 9 9900X, Radeon RX 9070 class (RDNA4), btrfs.
{ config, ... }:
{
  flake.modules.nixos."hosts/DarkJaguar" =
    { modulesPath, pkgs, ... }:
    {
      imports =
        (with config.flake.modules.nixos; [
          base
          desktop
          gaming
          printing
          amd
        ])
        ++ [ (modulesPath + "/installer/scan/not-detected.nix") ];

      networking.hostName = "DarkJaguar";
      nixpkgs.hostPlatform = "x86_64-linux";

      # Ryzen 9 9900X: 12C/24T desktop with fast storage; use all 12 cores.
      local.build.maxJobs = 12;

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
      ];
      boot.kernelModules = [ "kvm-amd" ];
      hardware.cpu.amd.updateMicrocode = true;

      # Keep the RX 9070 out of low-power P-states so shader compilation and
      # frame submission never stall waiting for a clock ramp.  Host-specific
      # because we do NOT want this on laptops (e.g. AsusZ13).
      systemd.services.amdgpu-perf = {
        description = "Force AMD GPU high performance level";
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-modules-load.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.bash}/bin/bash -c 'for f in /sys/class/drm/card*/device/power_dpm_force_performance_level; do [ -w \"\$f\" ] && echo high > \"\$f\"; done'";
        };
      };
      
      fileSystems."/" =
        { device = "/dev/disk/by-uuid/bf057802-9996-4085-8c04-7a931eb05f41";
          fsType = "ext4";
        };
    
      fileSystems."/boot" =
        { device = "/dev/disk/by-uuid/43C0-4920";
          fsType = "vfat";
          options = [ "fmask=0077" "dmask=0077" ];
        };
    
      swapDevices =
        [ { device = "/dev/disk/by-uuid/7863607d-0809-4418-bbe6-6f229ec1e7c0"; }
        ];

      system.stateVersion = "26.05";
    };
}

