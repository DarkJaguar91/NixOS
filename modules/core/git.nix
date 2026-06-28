{
  pkgs,
  usr,
  ...
}:
let
  gitConfig = pkgs.writeText "git-config" ''
    [user]
      name = ${usr.name}
      email = ${usr.email}

    [init]
      defaultBranch = main

    [pull]
      rebase = true

    [push]
      autoSetupRemote = true
  '';
in
{
  environment.systemPackages = [ pkgs.git ];

  environment.etc."tmpfiles.d/home-${usr.login}-git.conf".text = ''
    d  /home/${usr.login}/.config/git        0755 ${usr.login} users -
    L+ /home/${usr.login}/.config/git/config -    ${usr.login} -     - ${gitConfig}
  '';
}
