# Hermes Agent (Nous Research): self-hosted personal AI agent, the OpenClaw
# successor. Runs the messaging gateway as a hardened systemd service via
# upstream's NixOS module (native mode — fully declarative; container mode
# exists if the agent ever needs to apt/pip-install its own tools).
#
# addToSystemPackages puts the `hermes` CLI on PATH and points HERMES_HOME
# at the service state, so interactive `hermes` chats share sessions/skills
# with the gateway; the owner joins the hermes group for write access.
# Note: in managed mode `hermes setup`/`hermes config set` are blocked —
# config changes go through services.hermes-agent.settings here.
#
# Provider keys live in /var/lib/hermes/env (optional; skipped when absent):
#   echo 'OPENROUTER_API_KEY=sk-or-...' | sudo install -m 0600 -o hermes /dev/stdin /var/lib/hermes/env
#   sudo systemctl restart hermes-agent
{ config, inputs, ... }:
{
  flake.modules.nixos.desktop =
    { ... }:
    {
      imports = [ inputs.hermes.nixosModules.default ];

      services.hermes-agent = {
        enable = true;
        addToSystemPackages = true;
        environmentFiles = [ "/var/lib/hermes/env" ];

        # opencode-go is a first-class hermes provider; the key goes in
        # /var/lib/hermes/env as OPENCODE_GO_API_KEY (see header).
        settings.model = {
          provider = "opencode-go";
          default = "kimi-k3";
        };
      };

      # /var/lib/hermes is 2770 hermes:hermes; group membership lets the
      # interactive CLI read/write the shared state.
      users.users.${config.flake.meta.owner.username}.extraGroups = [ "hermes" ];
    };
}
