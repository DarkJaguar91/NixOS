# ASUS ROG Flow Z13 (2025), Ryzen AI Max "Strix Halo", ext4.
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

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/d2f9aca3-b93c-4e22-9e01-f6ccf89f2ac9";
        fsType = "ext4";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/3392-6030";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

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
