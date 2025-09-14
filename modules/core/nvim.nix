{ pkgs, usr, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim

    # Needed by many plugins
    git # Version control
    curl # Downloading (mason)
    unzip # Unzipper
    gnutar # Tarballs
    gzip # Gzip unzipper
    ripgrep # Better grep (telescope)
    fd # Find files

    # LSPs
    nil
    nixd
    nixfmt-rfc-style # Formatting nix files

    # Compilers
    gcc # Needed for treesitter
  ];

  # Because we are using Mason, we need a nix linker for mason installed lsps
  programs.nix-ld.enable = true;

  environment.etc."tmpfiles.d/home-${usr.login}-nvim.conf".text = ''
    L+    /home/${usr.login}/.config/nvim                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/nvim
  '';
}
