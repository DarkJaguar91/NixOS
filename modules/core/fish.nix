{
  pkgs,
  usr,
  nixConfigPath,
  ...
}:
{
  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    fishPlugins.tide
  ];

  environment.etc."tmpfiles.d/home-${usr.login}-fish.conf".text = ''
    L+    /home/${usr.login}/.config/fish                   -    ${usr.login}    -     -           ${nixConfigPath}/assets/dots/fish
  '';
}
