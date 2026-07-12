# nixpkgs unstable's orca-slicer 2.4.1 ships an unwrapped binary: wrapGAppsHook3
# is silently skipped under __structuredAttrs, so the GTK environment (pixbuf
# loaders, gsettings schemas, GIO modules, GStreamer plugin paths,
# WEBKIT_DISABLE_COMPOSITING_MODE) is never set. Symptoms: blank gray
# WebView pages (home/wizard/device tabs), broken SVG icons, Pango font-size
# assertion spam. Re-wrap the cached binary here instead of rebuilding from
# source; drop this once upstream nixpkgs wraps it again.
{
  lib,
  stdenvNoCC,
  wrapGAppsHook3,
  orca-slicer,
  glew,
  gtk3,
  glib-networking,
  librsvg,
  gsettings-desktop-schemas,
  dconf,
  gst_all_1,
}:

stdenvNoCC.mkDerivation {
  pname = "orca-slicer";
  inherit (orca-slicer) version meta;

  nativeBuildInputs = [ wrapGAppsHook3 ];

  # Mirrors what the 2.3.2 wrapper carried: pixbuf loaders (librsvg), gsettings
  # schemas (gtk3 + desktop-schemas), GIO modules (glib-networking TLS, dconf),
  # and the GStreamer plugins the device/liveview page probes for.
  buildInputs = [
    gtk3
    glib-networking
    librsvg
    gsettings-desktop-schemas
    dconf.lib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  dontUnpack = true;
  dontBuild = true;

  # The binary is copied (not symlinked) so wrapGAppsHook3 can wrap it in
  # place; share/ is symlinked so it still resolves resources via ../share.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ${orca-slicer}/bin/orca-slicer $out/bin/orca-slicer
    ln -s ${orca-slicer}/share $out/share
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${orca-slicer}/lib:${lib.makeLibraryPath [ glew ]}"
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1
    )
  '';
}
