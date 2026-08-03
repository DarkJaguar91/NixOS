# GDScript developer tooling: formatter, linter, and LSP support.
{ config, ... }:
{
  flake.modules.nixos.gamedev =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # gdtoolkit_4: gdformat + gdlint + gdparse for Godot 4 GDScript
        gdtoolkit_4
        # Faster standalone GDScript formatter (Rust)
        gdscript-formatter
      ];

      # Godot's editor doubles as the GDScript LSP server
      # (`godot4 --headless --lsp` / editor with LSP enabled on port 6005),
      # so neovim's built-in client can attach without extra packages.
    };
}
