{ config, pkgs, ... }:

{
  users.users.brandon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.fish;
  };
}
