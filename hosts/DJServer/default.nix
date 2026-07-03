{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  modules = {
    servarr.enable = true;
    recyclarr.enable = true;
    streaming.plex.enable = true;
    streaming.jellyfin.enable = true;
    immich.enable = true;
    dns.enable = true;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # default LTS kernel — ZFS lags behind linuxPackages_latest
    supportedFilesystems = [ "zfs" ];
    zfs.extraPools = [
      "fast"
      "media"
    ];
  };

  # TODO: replace with this machine's id: head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "8425e349";

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  # Both ethernet ports bonded into one logical interface.
  # balance-alb needs no switch support; use "802.3ad" instead if the
  # switch has LACP configured on these ports.
  # TODO: replace interface names with the real ones (`ip link` on the box)
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
      ipv4 = {
        method = "manual";
        addresses = "192.168.68.254/24";
        gateway = "192.168.68.1";
        dns = "127.0.0.1";
      };
    };

    bond0-port1 = {
      connection = {
        id = "bond0-port1";
        type = "ethernet";
        interface-name = "enp1s0";
        master = "bond0";
        slave-type = "bond";
      };
    };

    bond0-port2 = {
      connection = {
        id = "bond0-port2";
        type = "ethernet";
        interface-name = "enp2s0";
        master = "bond0";
        slave-type = "bond";
      };
    };
  };

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
