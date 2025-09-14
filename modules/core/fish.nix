{ pkgs, usr, ... }:
{
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    fishPlugins.tide
  ];

  environment.etc."tmpfiles.d/home-${usr.login}-fish.conf".text = ''
    L+    /home/${usr.login}/.config/fish                   -    ${usr.login}    -     -           /home/${usr.login}/.config/nixos/assets/dots/fish
  '';
}
