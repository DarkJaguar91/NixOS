# Agentic coding CLIs available on every host, so a rebuild or reboot never
# interrupts a conversation.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.claude-code
        pkgs.opencode
      ];
    };
}