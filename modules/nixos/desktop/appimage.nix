{
  flake.modules.nixos.desktop = {
    # Run AppImages directly: appimage-run wrapper + binfmt_misc registration
    # so AppImages execute seamlessly without an explicit wrapper.
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}