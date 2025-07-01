{
  pkgs,
  inputs,
  usr,
  host,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = false;
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs usr host; };

    users.${usr.login} = {
      imports = [ ../home ];
      home = {
        username = "${usr.login}";
        homeDirectory = "/home/${usr.login}";
        stateVersion = "25.05";
      };
    };
  };

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
      ];
      shell = pkgs.fish;
      ignoreShellProgramCheck = true;
    };
  };
  nix.settings.allowed-users = [ "${usr.login}" ];
}
