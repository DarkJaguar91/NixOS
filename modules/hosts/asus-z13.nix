# ASUS ROG Flow Z13 (2025), Ryzen AI Max "Strix Halo". ext4 root.
# Strix Halo: 16C/32T but a single memory-bound APU; it inherits the base
# default local.build.maxJobs=8, which keeps the machine responsive during
# rebuilds.
{ config, ... }:
let
  inherit (config.flake.meta) owner;
in
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
          amdgpu-gamemode-perf
          netbird
          asus-copilot-key
          backlight
          touchscreen-outputs
        ])
        ++ [ (modulesPath + "/installer/scan/not-detected.nix") ];

      networking.hostName = "AsusZ13";
      nixpkgs.hostPlatform = "x86_64-linux";

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
        user = owner.username;
        adjustor.enable = true;
      };
      environment.systemPackages = [ pkgs.handheld-daemon-ui ];

      # hhd emulates power-profiles-daemon (so noctalia's and Steam's power
      # profile switches drive TDP) by spawning `python -m
      # adjustor.drivers.gpu.ppd`. nixpkgs' wrapper only puts hhd's modules on
      # sys.path inside the main process, so that child dies with "No module
      # named 'adjustor'"; hand it the same path explicitly.
      systemd.services.handheld-daemon.environment.PYTHONPATH =
        let
          py = pkgs.python3;
          hhd = pkgs.handheld-daemon;
        in
        "${hhd}/${py.sitePackages}:${py.pkgs.makePythonPath hhd.dependencies}";

      # ...and let it own PPD's bus names: the system bus denies ownership
      # unless a policy allows it, and with the real daemon disabled nothing
      # does. Policy files only, so D-Bus can't activate the real PPD.
      services.dbus.packages = [
        (pkgs.runCommand "hhd-ppd-dbus-policy" { } ''
          mkdir -p $out/share/dbus-1
          cp -r ${pkgs.power-profiles-daemon}/share/dbus-1/system.d $out/share/dbus-1/
        '')
      ];

      # Hardware config
      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sdhci_pci"
      ];
      boot.kernelModules = [ "kvm-amd" ];
      hardware.cpu.amd.updateMicrocode = true;

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/832168d0-ddbf-44c7-b1b2-363aaa448bcf";
        fsType = "ext4";
      };
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/73C4-099C";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
      swapDevices = [ { device = "/dev/disk/by-uuid/28cfb13e-e947-4cc0-af46-94734cd8c0f2"; } ];

      # GPU clocks are toggled by amdgpu-gamemode-perf
      programs.gamemode.settings.general = {
        softrealtime = "auto";
        renice = 10;
      };

      system.stateVersion = "26.05";
    };
}
