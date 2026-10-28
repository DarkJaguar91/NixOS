# Shows Umbriel virtual outputs on XR glasses as screens fixed in space, using
# XRLinuxDriver's head pose (xr-viewer, see src/main.rs), plus xr-layout, a
# window for arranging those screens.
{
  lib,
  rustPlatform,
  makeDesktopItem,
  copyDesktopItems,
  pkg-config,
  libGL,
  libxkbcommon,
  wayland,
}:
rustPlatform.buildRustPackage {
  pname = "xr-viewer";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./src
    ];
  };

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ];
  buildInputs = [
    libGL
    wayland
  ];

  # xr-layout's windowing (winit/glutin) dlopens these rather than linking
  # them, and the shared wayland-sys feature makes xr-viewer dlopen
  # libwayland too
  postFixup = ''
    for bin in $out/bin/*; do
      patchelf --add-rpath ${
        lib.makeLibraryPath [
          libGL
          libxkbcommon
          wayland
        ]
      } $bin
    done
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "xr-layout";
      desktopName = "XR screen layout";
      comment = "Arrange the virtual screens shown on XR glasses";
      exec = "xr-layout";
      icon = "preferences-desktop-display";
      categories = [
        "Settings"
        "HardwareSettings"
      ];
    })
  ];

  meta = {
    description = "Fixed-in-space virtual screens for XR glasses on Umbriel";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "xr-viewer";
  };
}
