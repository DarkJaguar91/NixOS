{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          nerd-fonts.ubuntu
          nerd-fonts.ubuntu-mono
          nerd-fonts.ubuntu-sans
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
        ];

        fontconfig.defaultFonts = {
          sansSerif = [
            "Ubuntu Nerd Font"
            "Noto Sans"
          ];
          serif = [ "Noto Serif" ];
          monospace = [
            "UbuntuMono Nerd Font"
            "Noto Sans Mono"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
}
