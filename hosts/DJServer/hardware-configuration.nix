# PLACEHOLDER — replace with the output of `nixos-generate-config`
# run from the installer on the actual machine (OS NVMe only; the
# fast/media pools are imported via boot.zfs.extraPools, not listed here).
{ ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
}
