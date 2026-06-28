{
  pkgs,
  lib,
  nixpkgs,
  ...
}:

{
  imports = [ ./neovim.nix ];
  home.username = "brandon";
  home.homeDirectory = "/home/brandon";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    kdePackages.kate
  ];

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
    ];
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      shell = "fish";
    };
    shellIntegration.enableFishIntegration = true;
  };

  home.activation.setDefaultTerminal = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty
    ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key TerminalService kitty.desktop
    ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental 2>/dev/null || true
  '';

  programs.git = {
    enable = true;
    settings.user = {
      name = "Brandon Talbot";
      email = "bjtal91@gmail.com";
    };
  };

  programs.nixvim.nixpkgs.source = nixpkgs;
  programs.nixvim.version.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;
}
