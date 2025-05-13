{pkgs, ...}: {
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = true;
      package = pkgs.steam.override {
        extraLibraries = pkgs: [pkgs.xorg.libxcb];
        extraPkgs = pkgs:
          with pkgs; [
            xorg.libXcursor
            xorg.libXi
            xorg.libXinerama
            xorg.libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
            gamemode
          ];
      };
      extraCompatPackages = [pkgs.proton-ge-bin];
    };

    gamescope = {
      enable = true;
    };
  };

  # Add Heroic Launcher
  environment.systemPackages = with pkgs; [
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
      ];
    })
    mangohud # FPS Overlay
    goverlay # Configure Mangohud
    protonup-qt # Install Proton versions
  ];
}

