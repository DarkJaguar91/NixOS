{pkgs}:
pkgs.writeShellScriptBin "asus-profile-switch" ''
  asusctl profile -n

  PROFILE=$(asusctl profile -p | grep "Active profile" | grep -Po "\w+\$")

  notify-send "Profile: $PROFILE"
''
