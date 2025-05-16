{ ... }: {
  imports = [
    ./packages.nix
    ./services.nix
    ./greetd.nix # Login screen
  ];
}
