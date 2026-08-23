# Locale and keyboard configuration - part of base
{ config, ... }:
{
  flake.nixosModules.base =
    { ... }:
    {
      # Locale
      i18n.defaultLocale = "en_US.UTF-8";

      # Configure keymap
      console.keyMap = "us";
    };
}
