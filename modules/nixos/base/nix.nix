{
  flake.modules.nixos.base =
    { config, lib, ... }:
    let
      cfg = config.local.build;
    in
    {
      # Build parallelism is per-host (the dendritic hosts have different
      # CPUs). Declare the knob here, default it to something sane for all
      # hosts, and let each host override it to match its core count.
      options.local.build.maxJobs = lib.mkOption {
        type = lib.types.ints.positive;
        default = 8;
        description = ''
          nix.settings.max-jobs: how many derivations build in parallel.
          The nix default ("auto" => nproc) over-subscribes badly on
          high-thread-count machines — 32 jobs each told they may use all
          cores thrashes the scheduler and pushes memory into swap. Cap it
          per host instead. cores stays 0 so each job can still use every
          core, which is what you want once max-jobs is reasonable.
        '';
      };

      config = {
        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          auto-optimise-store = true;
          download-buffer-size = 268435456; # 256 MiB; large substitutions stall the default

          max-jobs = cfg.maxJobs;
          cores = 0; # each derivation may use all cores; parallelism is capped by max-jobs
        };

        # auto-optimise-store only dedups paths as they're written; anything
        # already in the store (or un-hardlinked by GC) never gets re-linked.
        # A monthly pass re-hardlinks identical files across the whole store.
        nix.optimise = {
          automatic = true;
          dates = [ "monthly" ];
        };

        nixpkgs.config.allowUnfree = true;
      };
    };
}
