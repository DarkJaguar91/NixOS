# Netdata host monitoring.
{
  flake.modules.nixos.server =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.netdata = {
        enable = true;
        # the plain netdata package ships no web UI at all (the dashboard is
        # NCUL1-licensed); netdataCloud bundles it — still fully local, no
        # cloud account involved
        package = pkgs.netdataCloud;
      };

      # the GPU collector execs nvidia-smi from the service's PATH; no root
      # needed, the /dev/nvidia* nodes are world-readable
      systemd.services.netdata.path = lib.optional (lib.elem "nvidia" config.services.xserver.videoDrivers) (
        lib.getBin config.hardware.nvidia.package
      );

      networking.firewall.allowedTCPPorts = [ 19999 ];
    };
}
