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
          gamedev
          printing
          laptop
          amd
          netbird
          disk-btrfs
        ])
        ++ [ (modulesPath + "/installer/scan/not-detected.nix") ];

      networking.hostName = "AsusZ13";
      nixpkgs.hostPlatform = "x86_64-linux";

      # Strix Halo: 16C/32T but a single memory-bound APU. 8 parallel
      # derivations keeps the machine responsive during rebuilds.
      local.build.maxJobs = 8;

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sdhci_pci"
      ];
      boot.kernelModules = [ "kvm-amd" ];
      hardware.cpu.amd.updateMicrocode = true;

      # Strix Halo display/GPU quirks
      boot.kernelParams = [
        "amdgpu.sg_display=0"
        "amdgpu.abmlevel=0"
        "amdgpu.dcdebugmask=0x600"
        "amdgpu.cwsr_enable=0"
        "iommu=pt"
      ];

      # Consumed by the disk-btrfs module (LUKS + btrfs, subvols rootfs/nix/home)
      local.disk = {
        device = "/dev/disk/by-id/nvme-Sabrent_Rocket_Q4_48801681708472_1";
        encrypted = true;
      };

      # Fresh installs get this login until rotated with passwd; inert once a
      # password exists (all current machines have one). No sshd on this host.
      users.users.brandon.initialPassword = "nixos";

      # screen auto-rotation
      hardware.sensor.iio.enable = true;

      # TDP / fan control for the Strix Halo APU. Also owns the battery charge
      # limit (hhd-ui -> Battery Settings), which writes BAT0's
      # charge_control_end_threshold.
      services.handheld-daemon = {
        enable = true;
        user = "brandon";
        adjustor.enable = true;
        # nixpkgs' 4.1.10 imports pkg_resources, gone from setuptools 82, so
        # the service crash-loops; 4.1.11 moved to importlib.metadata.
        # Drop this override once nixpkgs ships >= 4.1.11.
        package = pkgs.handheld-daemon.overridePythonAttrs (old: rec {
          version = "4.1.12";
          src = pkgs.fetchFromGitHub {
            owner = "hhd-dev";
            repo = "hhd";
            tag = "v${version}";
            hash = "sha256-Cv6kDrPm8AIB+JleZ8e17NF3EX+lOFk4Ndc1eJO3J8Y=";
          };
        });
      };
      environment.systemPackages = [ pkgs.handheld-daemon-ui ];

      system.stateVersion = "26.05";
    };
}
