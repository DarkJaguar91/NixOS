{
  pkgs,
  usr,
  ...
}:
{
  users = {
    mutableUsers = true;

    users.${usr.login} = {
      isNormalUser = true;
      description = usr.name;
      extraGroups = [
        "libvirtd"
        "lp"
        "networkmanager"
        "wheel"
        "inputs"
      ];
      shell = pkgs.fish;
      ignoreShellProgramCheck = true;
    };
  };
  nix.settings.allowed-users = [ "${usr.login}" ];
}
