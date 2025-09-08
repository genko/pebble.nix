{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,

  expat,
  ncurses5,
  python2,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pebble-toolchain-bin";
  version = "4.6-rc2";

  src =
    (rec {
      x86_64-linux = fetchzip {
        url = "https://rebble-sdk.s3-us-west-2.amazonaws.com/pebble-sdk-${finalAttrs.version}-linux64.tar.bz2";
        hash = "3503be2ced6fe529f558e94a543515a0da8df12204ee58519388ae857f494c92";
      };
      x86_64-darwin = fetchzip {
        url = "https://rebble-sdk.s3-us-west-2.amazonaws.com/pebble-sdk--${finalAttrs.version}-mac.tar.bz2";
        hash = "sha256-DgT75r0pxxyL1csxEvyDC4KO+Yv8sSfA5LSVXCVefZ0=";
      };
      aarch64-darwin = x86_64-darwin;
    }).${stdenv.hostPlatform.system};

  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;
  buildInputs =
    [ python2 ]
    ++ (lib.optionals stdenv.hostPlatform.isLinux [
      expat
      ncurses5
      python2
      zlib
    ]);

  installPhase = ''
    mv arm-cs-tools $out
  '';

  fixupPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # TODO: this doesn't work on apple silicon. figure out how to conjure an x86_64 python2 on there
    install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python ${python2}/lib/libpython2.7.dylib $out/bin/arm-none-eabi-gdb
  '';
})
