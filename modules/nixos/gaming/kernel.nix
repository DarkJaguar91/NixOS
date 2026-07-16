# CachyOS kernel from chaotic-nyx (BORE scheduler, gaming-tuned). The chaotic
# module registers its overlay and binary cache, so the kernel comes prebuilt.
{ inputs, ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      imports = [ inputs.chaotic.nixosModules.default ];

      boot.kernelPackages = pkgs.linuxPackages_cachyos;

      # sched-ext userspace scheduler; lavd is the latency-focused one CachyOS
      # recommends for gaming
      services.scx = {
        enable = true;
        scheduler = "scx_lavd";
      };
    };
}
