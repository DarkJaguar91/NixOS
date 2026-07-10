{
  config,
  lib,
  pkgs,
  usr,
  nixConfigPath,
  ...
}:

let
  cfg = config.modules.steam;

  # ReShade shaders for vkBasalt: SweetFX (Vibrance, Tonemap, ...) merged with
  # crosire's base repo, which provides the ReShade.fxh headers SweetFX includes.
  reshadeShaders =
    let
      base = pkgs.fetchFromGitHub {
        owner = "crosire";
        repo = "reshade-shaders";
        rev = "6db142b4b1a05c764222e5b0bd9a644b7ccfe1dc";
        hash = "sha256-WqT4eU8ZlGwKEgUEGlivz+35GprKX4goBeLnp9D5lTY=";
      };
      sweetfx = pkgs.fetchFromGitHub {
        owner = "CeeJayDK";
        repo = "SweetFX";
        rev = "16d1a42247cb5baaf660120ee35c9a33bb94649c";
        hash = "sha256-h7nqn4aQHomrI/NG0Oj2R9bBT8VfzRGVSZ/CSi/Ishs=";
      };
    in
    pkgs.runCommand "reshade-shaders" { } ''
      mkdir -p $out/Shaders $out/Textures
      cp -r ${base}/Shaders/. ${sweetfx}/Shaders/SweetFX/. $out/Shaders/
      cp -r ${base}/Textures/. ${sweetfx}/Textures/SweetFX/. $out/Textures/
      chmod -R u+w $out

      # Tonemap's stock FogColor is pure blue, so any Defog yellow-shifts the
      # image. Neutral white makes Defog a plain haze/contrast lift instead.
      # (float3 uniforms can't be overridden from vkBasalt.conf, only scalars.)
      substituteInPlace $out/Shaders/Tonemap.fx \
        --replace-fail "float3(0.0, 0.0, 1.0)" "float3(1.0, 1.0, 1.0)"
    '';
in
{
  options.modules.steam = {
    enable = lib.mkEnableOption "Steam gaming setup";
    decky.enable = lib.mkEnableOption "Decky Loader plugin manager (desktop mode)";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      steam = {
        enable = true;
        # tzdata 2026b changed America/Vancouver's DST rules to ones Wine can't
        # map to any Windows timezone ("find_reg_tz_info: Can't find matching
        # timezone information"), so Proton apps that look up the local zone
        # (GW2 addon loader, Blish HUD) fail-fast at launch. Pin Steam to a
        # zone Wine still recognizes; LA keeps Pacific wall time.
        #
        # NixOS also exports TZDIR=/etc/zoneinfo globally, but that path
        # doesn't exist inside the pressure-vessel runtime container, so glibc
        # there fails to resolve TZ at all and Rust apps that unwrap
        # local-time (e.g. Gw2-Simple-Addon-Loader) abort with c0000409.
        # Point TZDIR at a path valid in both the FHS env and the container.
        package = pkgs.steam.override {
          extraEnv = {
            TZ = "America/Los_Angeles";
            TZDIR = "/usr/share/zoneinfo";
          };
        };
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        gamescopeSession.enable = true;
      };
      gamescope = {
        enable = true;
        # capSysNice grants CAP_SYS_NICE ambiently, which leaks into Steam's
        # bwrap sandbox and kills the gamescope session at launch:
        # "bwrap: Unexpected capabilities but not setuid"
        capSysNice = false;
        # Steam prepends STEAM_RUNTIME_LIBRARY_PATH to LD_LIBRARY_PATH before
        # launching any child, including gamescope. NixOS binaries use
        # DT_RUNPATH (lower priority than LD_LIBRARY_PATH), so gamescope ends
        # up loading the Steam runtime's ancient libstdc++ and immediately
        # crashes with missing GLIBCXX symbols. Unsetting LD_LIBRARY_PATH
        # before exec lets gamescope fall back to its RUNPATH (nix store).
        # steam-launch-wrapper reconstructs LD_LIBRARY_PATH from
        # STEAM_RUNTIME_LIBRARY_PATH anyway, so the game still gets the right
        # Steam runtime libraries.
        package = pkgs.symlinkJoin {
          name = "gamescope-steam-fixed";
          paths = [ pkgs.gamescope ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/gamescope \
              --unset LD_LIBRARY_PATH
          '';
        };
      };
      gamemode.enable = true;
    };

    environment.systemPackages = with pkgs; [
      mangohud
      protonplus
      protontricks
      goverlay
      vkbasalt
      pkgsi686Linux.vkbasalt # 32-bit games
    ];

    # vkBasalt: config lives in dots/, shaders come from the nix store via a
    # stable symlink so the conf can reference fixed paths.
    environment.etc."tmpfiles.d/home-${usr.login}-vkbasalt.conf".text = ''
      L+ /home/${usr.login}/.config/vkBasalt/vkBasalt.conf - ${usr.login} - - ${nixConfigPath}/dots/vkbasalt/vkBasalt.conf
      L+ /home/${usr.login}/.config/vkBasalt/reshade - ${usr.login} - - ${reshadeShaders}
    '';

    # Decky Loader: standalone in desktop mode, no Jovian steam session needed.
    # CEF remote debugging lets Decky inject into Steam's UI.
    jovian.decky-loader.enable = lib.mkIf cfg.decky.enable true;

    systemd.tmpfiles.rules = lib.mkIf cfg.decky.enable [
      "d /home/${usr.login}/.local/share/Steam 0700 ${usr.login} users -"
      "f /home/${usr.login}/.local/share/Steam/.cef-enable-remote-debugging 0644 ${usr.login} users -"
    ];
  };
}
