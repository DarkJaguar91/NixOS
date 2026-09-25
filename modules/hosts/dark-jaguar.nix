# Desktop: Ryzen 9 9900X, Radeon RX 9070 class (RDNA4), ext4 root.
{ config, ... }:
{
  flake.modules.nixos."hosts/DarkJaguar" =
    { modulesPath, ... }:
    {
      imports =
        (with config.flake.modules.nixos; [
          base
          desktop
          gaming
          printing
          amd
          amdgpu-gamemode-perf
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

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/bf057802-9996-4085-8c04-7a931eb05f41";
        fsType = "ext4";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/43C0-4920";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
      swapDevices = [ { device = "/dev/disk/by-uuid/7863607d-0809-4418-bbe6-6f229ec1e7c0"; } ];

      system.stateVersion = "26.05";
    };
}
