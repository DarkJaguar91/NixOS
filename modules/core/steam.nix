{pkgs, ...}: {
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = true;
      extraCompatPackages = [pkgs.proton-ge-bin];
    };

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
  };

  # Add Heroic Launcher
  environment.systemPackages = with pkgs; [
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
      ];
    })
  ];
}
