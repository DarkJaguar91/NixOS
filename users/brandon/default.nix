{
  pkgs,
  lib,
  nixpkgs,
  nixosConfig,
  ...
}:

let
  screenshotScript = pkgs.writeShellScript "nixos-screenshot" ''
    TMPFILE=$(mktemp /tmp/screenshot-XXXXXX.png)
    spectacle --region --background --nonotify --output "$TMPFILE" && swappy -f "$TMPFILE"
    rm -f "$TMPFILE"
  '';
  screenrecordScript = pkgs.writeShellScript "nixos-screenrecord" ''
    if pgrep spectacle > /dev/null; then
      pkill spectacle
    else
      spectacle --record region
    fi
  '';
in

{
  imports = [ ./neovim.nix ] ++ lib.optional nixosConfig.modules.mangowc.enable ./mangowc.nix;

  home = {
    username = "brandon";
    homeDirectory = "/home/brandon";
    stateVersion = "26.05";
    packages = with pkgs; [
      kdePackages.kate
    ];
    activation.setDefaultTerminal = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty
      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group General --key TerminalService kitty.desktop
      ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental 2>/dev/null || true
    '';
  };

  programs = {
    fish = {
      enable = true;
      plugins = [
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
      ];
    };
    kitty = {
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
    git = {
      enable = true;
      settings = {
        user = {
          name = "Brandon Talbot";
          email = "bjtal91@gmail.com";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    mangohud.enable = nixosConfig.modules.gaming.enable;
    nixvim = {
      nixpkgs.source = nixpkgs;
      version.enableNixpkgsReleaseCheck = false;
    };
    home-manager.enable = true;
  };

  xdg.desktopEntries = lib.mkIf nixosConfig.modules.desktop.plasma.enable {
    nixos-screenshot = {
      name = "Screenshot (Select Area)";
      exec = "${screenshotScript}";
      noDisplay = true;
    };
    nixos-screenrecord = {
      name = "Screen Recording (Toggle)";
      exec = "${screenrecordScript}";
      noDisplay = true;
    };
  };

  home.activation.kdeShortcuts = lib.mkIf nixosConfig.modules.desktop.plasma.enable (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
        --file kglobalshortcutsrc \
        --group "nixos-screenshot.desktop" \
        --key "_launch" "Meta+S,none,Take Screenshot"
      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
        --file kglobalshortcutsrc \
        --group "nixos-screenrecord.desktop" \
        --key "_launch" "Meta+Shift+S,none,Toggle Screen Recording"
    ''
  );
}
