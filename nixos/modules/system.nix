{ host, ... }: {
  nix.settings = {
    download-buffer-size = 250000000;
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  
  time.timeZone = "America/Vancouver";
  console.keyMap = "us";

  system.stateVersion = "24.11";
}
