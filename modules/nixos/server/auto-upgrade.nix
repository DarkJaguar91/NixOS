# Applies whatever has been pushed to the dendritic branch, daily. Inputs
# only move when someone pushes an updated flake.lock, so builds stay
# reproducible from the lockfile — test locally, push, and the server picks
# it up overnight. Only the server gets this: an unattended `switch` on a
# desktop mid-session (or mid-game) is rude.
{
  flake.modules.nixos.server = {
    system.autoUpgrade = {
      enable = true;
      # no #fragment: nixos-rebuild defaults to nixosConfigurations.<hostname>
      flake = "github:DarkJaguar91/NixOS/dendritic";
      dates = "04:30";
      randomizedDelaySec = "30min";
      # Kernel/bootloader updates take effect on the next manual reboot.
      allowReboot = false;
    };
  };
}
