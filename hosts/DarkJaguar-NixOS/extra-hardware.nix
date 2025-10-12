{ ... }:
{
  # disable the AMD GPU so we only use the Nvidia card
  boot.kernelParams = [ "module_blacklist=amdgpu" ];

  fileSystems."/DarkJaguar" = {
    device = "/dev/disk/by-uuid/d335805c-8243-48ab-8493-c900035ee410";
    fsType = "ext4";
  };

  # Enable wooting keyboard
  hardware.wooting.enable = true;
}
