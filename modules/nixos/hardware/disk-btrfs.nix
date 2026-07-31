# Shared disk layout: 1G ESP + one btrfs partition with subvolumes for /,
# /nix and /home, optionally wrapped in LUKS (Z13 — it travels). disko
# generates fileSystems and the initrd unlock wiring from this same spec, and
# `disko-install --flake .#<host>` consumes it for bare-metal installs, so a
# fresh machine is: boot ISO, one command, done.
#
# DarkJaguar/DJServer predate this module (hand-written fileSystems, top-level
# "/" instead of a rootfs subvolume); adopt here only on their next reinstall.
{ inputs, ... }:
{
  flake.modules.nixos.disk-btrfs =
    { config, lib, ... }:
    let
      cfg = config.local.disk;
      btrfs = {
        type = "btrfs";
        subvolumes = {
          "/rootfs" = {
            mountpoint = "/";
          };
          "/nix" = {
            mountpoint = "/nix";
          };
          "/home" = {
            mountpoint = "/home";
          };
        };
      };
    in
    {
      imports = [ inputs.disko.nixosModules.disko ];

      options.local.disk = {
        device = lib.mkOption {
          type = lib.types.str;
          description = "Disk to partition, by-id path so it survives renumbering.";
        };
        encrypted = lib.mkEnableOption "LUKS full-disk encryption";
      };

      config.disko.devices.disk.main = {
        device = cfg.device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            root = {
              size = "100%";
              content =
                if cfg.encrypted then
                  {
                    type = "luks";
                    name = "cryptroot";
                    # NVMe: lets fstrim/btrfs discard through the LUKS layer
                    settings.allowDiscards = true;
                    content = btrfs;
                  }
                else
                  btrfs;
            };
          };
        };
      };
    };
}
