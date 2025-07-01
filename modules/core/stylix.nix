{
  pkgs,
  inputs,
  theme,
  ...
}: let
  style =
    if (theme != null)
    then theme
    else "tokyo-night-storm";
in {
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  # Styling Options
  stylix = {
    enable = true;
    image = ../../assets/Anime-Girl-Night-Sky.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${style}.yaml";
    polarity = "dark";
    opacity.terminal = 1.0;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
