# Fonts configuration - part of base
{ config, ... }:
{
  flake.nixosModules.base =
    { pkgs, ... }:
    {
      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          # Ubuntu Nerd Font
          nerd-fonts.ubuntu-mono

          # Other common fonts
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          liberation_ttf
        ];

        fontconfig = {
          defaultFonts = {
            serif = [ "Noto Serif" "Liberation Serif" ];
            sansSerif = [ "Noto Sans" "Liberation Sans" ];
            monospace = [ "UbuntuMono Nerd Font" "Liberation Mono" ];
            emoji = [ "Noto Color Emoji" ];
          };
        };
      };
    };
}
