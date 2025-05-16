{ username, pkgs, ... }: {
  users.mutableUsers = true;

  users.users = {
    ${username} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # sudo access
	      "networkmanager" # network access
				"libvirtd"
				"scanner"
				"lp"
				"video"
				"input"
				"audio"
      ];
      shell = pkgs.fish;
    };
  };

  nix.settings.allowed-users = ["${username}"];
}
