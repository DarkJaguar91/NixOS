# Alternative terminal agent alongside claude-code; handy for pointing at the
# self-hosted ollama models on the server.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.opencode ];
    };
}
