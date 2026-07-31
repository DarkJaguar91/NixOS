# `nix fmt` formats the whole tree. nixfmt-tree walks the tree itself (plain
# nixfmt deprecated taking directories, and `nix fmt` passes no arguments),
# formats .nix files in place with RFC-style nixfmt, and ignores the rest.
{
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;
    };
}
