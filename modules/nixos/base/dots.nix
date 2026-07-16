# Declarative dotfiles without home-manager: symlinks from $HOME into this
# repo's dotfiles/ directory, managed by systemd-tmpfiles. Links point at the
# repo checkout (not the nix store), so edits apply live without a rebuild
# while still being version-controlled.
#
# Usage from any module:
#   dots.files.".config/kitty/kitty.conf" = "kitty/kitty.conf";
#   dots.directories.".config/nvim" = "nvim";
{ config, ... }:
let
  inherit (config.flake) meta;
in
{
  flake.modules.nixos.base =
    { config, lib, ... }:
    let
      cfg = config.dots;
      user = meta.owner.username;
      home = "/home/${user}";

      parentRules = lib.pipe (lib.attrNames cfg.files ++ lib.attrNames cfg.directories) [
        (map dirOf)
        (lib.filter (dir: dir != "."))
        lib.unique
        (map (dir: "d ${home}/${dir} 0755 ${user} users -"))
      ];

      fileRules = lib.mapAttrsToList (
        target: source: "L+ ${home}/${target} - ${user} users - ${cfg.root}/${source}"
      ) cfg.files;

      dirRules = lib.concatLists (
        lib.mapAttrsToList (target: source: [
          # tmpfiles won't replace a real directory with a symlink; remove
          # whatever is there first
          "R ${home}/${target} - - - -"
          "L+ ${home}/${target} - ${user} users - ${cfg.root}/${source}"
        ]) cfg.directories
      );
    in
    {
      options.dots = {
        root = lib.mkOption {
          type = lib.types.str;
          default = "${meta.flakePath}/dotfiles";
          description = "Absolute path to this repo's dotfiles directory on the host.";
        };

        files = lib.mkOption {
          type = with lib.types; attrsOf str;
          default = { };
          description = "Home-relative symlink -> dotfiles-relative source, for single files.";
        };

        directories = lib.mkOption {
          type = with lib.types; attrsOf str;
          default = { };
          description = ''
            Home-relative symlink -> dotfiles-relative source, for whole
            directories. Anything already at the target is deleted, so only
            use this for directories fully owned by the repo.
          '';
        };
      };

      config.systemd.tmpfiles.rules = parentRules ++ dirRules ++ fileRules;
    };
}
