{ usr, ... }:
{
  programs.git = {
    enable = true;
    userName = usr.name;
    userEmail = usr.email;
  };
}
