# wheaney/XRLinuxDriver: user-space driver for XR glasses (VITURE, XREAL,
# Rokid, RayNeo). It reads the glasses' IMU and publishes head pose over
# System V shared memory, which the umbriel XR viewer consumes. VITURE and
# Rokid support links against closed-source vendor SDKs vendored in lib/.
{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  cargo,
  cmake,
  rustPlatform,
  rustc,
  pkg-config,
  python3,
  curl,
  json_c,
  libevdev,
  libusb1,
  openssl,
  wayland,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xr-linux-driver";
  version = "2.11.9";

  src = fetchFromGitHub {
    owner = "wheaney";
    repo = "XRLinuxDriver";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-3h2iHLxCrhtlV2bpq/tYCxTh8nL77WU3pqZ/Adpn+uQ=";
  };

  # The XREAL One support is a Rust crate built by cargo from inside CMake.
  cargoRoot = "modules/xrealOneDeviceKit/modules/xreal_one_driver";
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src cargoRoot;
    hash = "sha256-ISgdmB5MEZ3P9KWCeURzr1PbIeb4BOCf1Z+Rs8wnJdM=";
  };

  # Submodules are already fetched; the build would otherwise shell out to git.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "execute_process(COMMAND git submodule" "message(STATUS git submodule"
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    cargo
    cmake
    rustPlatform.cargoSetupHook
    rustc
    pkg-config
    (python3.withPackages (ps: [ ps.pyyaml ]))
  ];

  buildInputs = [
    curl
    json_c
    libevdev
    libusb1
    openssl
    wayland
    stdenv.cc.cc.lib
  ];

  # Upstream points the build RPATH into the source tree; use $out/lib instead,
  # which also covers the RayNeo SDK that is dlopen'd rather than linked.
  cmakeFlags = [ (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true) ];
  appendRunpaths = [ "${placeholder "out"}/lib" ];

  # Upstream has no install rule; its packaging script copies the binary and
  # ships the vendor SDKs alongside it.
  installPhase = ''
    runHook preInstall
    install -Dm755 xrDriver $out/bin/xrDriver
    mkdir -p $out/lib
    cp -P ../lib/${stdenv.hostPlatform.uname.processor}/*.so* $out/lib/
    cp -P ../lib/${stdenv.hostPlatform.uname.processor}/viture/*.so* $out/lib/
    install -Dm644 -t $out/lib/udev/rules.d ../udev/*.rules
    runHook postInstall
  '';

  meta = {
    description = "Linux service for interacting with XR glasses";
    homepage = "https://github.com/wheaney/XRLinuxDriver";
    license = with lib.licenses; [
      gpl3Only
      unfreeRedistributable # vendored VITURE/Rokid/RayNeo SDKs
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "xrDriver";
  };
})
