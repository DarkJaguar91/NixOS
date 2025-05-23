{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    audacity
    nodejs
    cheese
    zoom-us
  ];
}
