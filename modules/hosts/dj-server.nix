# Headless server: Intel, RTX 2000 Ada, btrfs root + ZFS data pools.
{ config, ... }:
{
  flake.modules.nixos."hosts/DJServer" =
    { modulesPath, ... }:
    {
      imports =
        (with config.flake.modules.nixos; [
          base
          nvidia
          netbird # mesh access alongside the PiKVM routing peer
          server
        ])
        ++ [ (modulesPath + "/installer/scan/not-detected.nix") ];

      networking.hostName = "DJServer";
      nixpkgs.hostPlatform = "x86_64-linux";

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "ahci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "sr_mod"
      ];
      boot.kernelModules = [ "kvm-intel" ];
      hardware.cpu.intel.updateMicrocode = true;

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/12a9371e-547e-4a2a-b48c-ac651ad36fc3";
        fsType = "btrfs";
      };
      fileSystems."/nix" = {
        device = "/dev/disk/by-uuid/12a9371e-547e-4a2a-b48c-ac651ad36fc3";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };
      fileSystems."/home" = {
        device = "/dev/disk/by-uuid/12a9371e-547e-4a2a-b48c-ac651ad36fc3";
        fsType = "btrfs";
        options = [ "subvol=home" ];
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/4022-9A02";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
      swapDevices = [ { device = "/dev/disk/by-uuid/f35f5159-7056-4c66-9b47-d979003e9f19"; } ];

      # ZFS data pools
      networking.hostId = "b13430a2"; # required by ZFS
      boot.supportedFilesystems = [ "zfs" ];
      boot.zfs.forceImportRoot = false;
      boot.zfs.extraPools = [
        "fast"
        "media"
      ];
      services.zfs = {
        autoScrub.enable = true;
        trim.enable = true;
      };

      # immich's postgres on the fast pool (dataset has mountpoint=legacy)
      fileSystems."/var/lib/postgresql" = {
        device = "fast/immich-pg";
        fsType = "zfs";
      };

      # Both ethernet ports bonded into one logical interface; balance-alb
      # needs no switch support.
      networking.networkmanager.ensureProfiles.profiles = {
        bond0 = {
          connection = {
            id = "bond0";
            type = "bond";
            interface-name = "bond0";
          };
          bond = {
            mode = "balance-alb";
            miimon = "100";
          };
          # Pin the bond to port1's permanent hardware MAC; otherwise the
          # kernel generates a random locally-administered MAC on every boot.
          ethernet.cloned-mac-address = "00:E0:4C:0F:31:D6";
          ipv4 = {
            method = "manual";
            addresses = "192.168.68.254/24";
            gateway = "192.168.68.1";
            # keyfile format: semicolon-separated, unlike nmcli's commas
            dns = "1.1.1.1;8.8.8.8;";
            ignore-auto-dns = true;
          };
        };
        bond0-port1 = {
          connection = {
            id = "bond0-port1";
            type = "ethernet";
            interface-name = "enp94s0";
            master = "bond0";
            slave-type = "bond";
          };
        };
        bond0-port2 = {
          connection = {
            id = "bond0-port2";
            type = "ethernet";
            interface-name = "enp95s0";
            master = "bond0";
            slave-type = "bond";
          };
        };
      };

      services.openssh.enable = true;

      # headless box with no geoclue-usable radios; base leaves the timezone
      # to automatic-timezoned only on desktop hosts
      time.timeZone = "America/Vancouver";

      system.stateVersion = "26.05";
    };
}
