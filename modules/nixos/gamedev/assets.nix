# 3D-focused asset pipeline: modeling, procedural materials, and audio.
{
  flake.modules.nixos.gamedev =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Modeling / sculpting / animation; glTF exporter imports cleanly
        # into Godot 4
        blender
        # Procedural PBR material authoring (Substance-style, exports to
        # Godot-friendly textures)
        material-maker
        # Audio recording / cleanup for SFX and VO
        audacity
      ];
    };
}
