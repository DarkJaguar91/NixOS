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
    d /home/${usr.login}/.config/fish 0755 ${usr.login} users -
    L+ /home/${usr.login}/.config/fish/config.fish - ${usr.login} - - ${nixConfigPath}/dots/fish/config.fish
  '';
}
