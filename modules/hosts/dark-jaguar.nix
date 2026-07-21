# Desktop: Ryzen 9 9900X, Radeon RX 9070 class (RDNA4), btrfs.
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
        ])
        ++ [ (modulesPath + "/installer/scan/not-detected.nix") ];

      networking.hostName = "DarkJaguar";
      nixpkgs.hostPlatform = "x86_64-linux";

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
      ];
      boot.kernelModules = [ "kvm-amd" ];
      hardware.cpu.amd.updateMicrocode = true;

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/4b362b4f-4e33-4eda-b02a-c085831ea3a9";
        fsType = "btrfs";
      };
      fileSystems."/nix" = {
        device = "/dev/disk/by-uuid/4b362b4f-4e33-4eda-b02a-c085831ea3a9";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };
      fileSystems."/home" = {
        device = "/dev/disk/by-uuid/4b362b4f-4e33-4eda-b02a-c085831ea3a9";
        fsType = "btrfs";
        options = [ "subvol=home" ];
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/7F1D-3663";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
      fileSystems."/storage" = {
        device = "/dev/disk/by-uuid/c6ad7265-5c71-4fe1-85a9-4e5e77282909";
        fsType = "btrfs";
        options = [ "nofail" ];
      };

      system.stateVersion = "26.05";
    };
}
