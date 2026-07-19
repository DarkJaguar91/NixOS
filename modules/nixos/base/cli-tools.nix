# Modern CLI staples: fzf (fuzzy finder), bat (better cat), eza (better ls),
# zoxide (smarter cd). Their fish integrations and aliases live in
# dotfiles/fish/config.fish.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        bat
        eza
        fzf
        zoxide
      ];
    };
}
