{
  pkgs,
  nixpkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    audacity
    nodejs
  ];

  nixpkgs.overlays = [
    (self: prev: {
      orca-slicer = prev.orca-slicer.overrideAttrs (oldAttrs: {
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            substituteInPlace $out/share/applications/OrcaSlicer.desktop \
             --replace "orca-slicer %U" "env __GLX_VENDOR_LIBRARY_NAME=mesa __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink WEBKIT_DISABLE_DMABUF_RENDERER=1 orca-slicer %U"
          '';
      });
    })
  ];
}
