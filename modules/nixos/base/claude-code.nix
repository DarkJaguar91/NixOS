# Available on every host, so a rebuild/reboot never interrupts a conversation.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.claude-code ];
    };
}
