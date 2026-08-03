# Python toolchain: python3 + pip + venv support. Declarative system install;
# project dependencies still go into per-project virtualenvs created with
# `python3 -m venv`.
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        python3
        python3Packages.pip
        python3Packages.virtualenv
      ];
    };
}
