{ ... }:
{
  # disable the AMD GPU so we only use the Nvidia card
  boot.kernelParams = [ "module_blacklist=amdgpu" ];

  # enable the Windows drive D
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/DarkJaguar" = {
    device = "/dev/disk/by-uuid/5ED894AED89485C5";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
    ];
  };
}
