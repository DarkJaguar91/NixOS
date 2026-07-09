{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  modules = {
    ai-tools.enable = true; # claude-code
    gpu.nvidia.enable = true; # RTX 2000 Ada — NVENC transcoding + Immich ML
    netbird.enable = true; # mesh access alongside the PiKVM routing peer
    caddy.enable = true; # public HTTPS for jellyfin + seerr + immich only

    homepage.enable = true; # dashboard at http://192.168.68.254:8082
    ollama.enable = true; # local LLMs on the RTX 2000 Ada + Open WebUI
    servarr.enable = true;
    recyclarr.enable = true;
    seerr.enable = true;
    netdata.enable = true;
    streaming.plex.enable = true;
    streaming.jellyfin.enable = true;
    immich.enable = true;
  };

  networking = {
    hostName = "DJServer";
    hostId = "b13430a2"; # required by ZFS

    # Both ethernet ports bonded into one logical interface; balance-alb
    # needs no switch support
    networkmanager.ensureProfiles.profiles = {
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
        # kernel generates a random locally-administered MAC on every boot
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
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    zfs.extraPools = [
      "fast"
      "media"
    ];
  };

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  fileSystems."/var/lib/postgresql" = {
    device = "fast/immich-pg";
    fsType = "zfs";
  };

  services.openssh.enable = true;

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
