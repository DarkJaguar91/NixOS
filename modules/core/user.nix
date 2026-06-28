{
  pkgs,
  usr,
  ...
}:
{
  users = {
    users.${usr.login} = {
      isNormalUser = true;
      description = usr.name;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.fish;
    };
  };
  nix.settings.allowed-users = [ "${usr.login}" ];

  security.sudo.wheelNeedsPassword = false;
}
