# Self-hosted AI agent. The package bundles its Control UI (built at package
# time), which the gateway serves on localhost:18789 — `openclaw dashboard`
# opens it. Sits alongside claude-code so it survives rebuilds the same way.
{
  flake.modules.nixos.base =
    { lib, pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.openclaw ];

      # nixpkgs marks openclaw insecure: it feeds untrusted content to an LLM
      # that has full system access, so prompt injection is a live risk.
      # Matching on the name rather than name-version keeps version bumps on
      # unstable from breaking rebuilds.
      nixpkgs.config.allowInsecurePredicate = pkg: lib.getName pkg == "openclaw";
    };
}
