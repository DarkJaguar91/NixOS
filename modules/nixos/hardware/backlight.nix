{
  flake.modules.nixos.backlight =
    { pkgs, ... }:
    {
      # /sys/class/backlight/*/brightness ships as root:root 0644, and this
      # system's gamescope session isn't reliably logind's "active" session
      # (steamos-manager doesn't own brightness at all, and anything relying
      # on logind's session-active-gated SetBrightness D-Bus call - Steam's
      # own slider included - silently fails while it isn't). Grant the
      # video group direct write access instead, sidestepping that entirely.
      services.udev.extraRules = ''
        SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
      '';

      users.users.brandon.extraGroups = [ "video" ];
    };
}
