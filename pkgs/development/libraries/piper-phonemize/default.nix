{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, espeak-ng
}:

let
  espeak-ng' = espeak-ng.overrideAttrs (oldAttrs: {
    version = "1.52-dev";
    src = fetchFromGitHub {
      owner = "rhasspy";
      repo = "espeak-ng";
      rev = "61504f6b76bf9ebbb39b07d21cff2a02b87c99ff";
      hash = "sha256-RBHL11L5uazAFsPFwul2QIyJREXk9Uz8HTZx9JqmyIQ=";
    };

    patches = [
      ./espeak-mbrola.patch
    ];
  });
in
stdenv.mkDerivation rec {
  pname = "piper-phonemize";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "piper-phonemize";
    rev = "v${version}";
    hash = "sha256-/uprYRLbf5qPOBdAN+bvRwxrGyChhDb2ZjS5gZMr/b8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    espeak-ng'
  ];

  installPhase = ''
    runHook preInstall
    find . -iname "libpiper_phonemize.so"
    install -m0755 -d $out/lib
    install -m0664 ./libpiper_phonemize.so $out/lib
    runHook postInstall
  '';

  passthru = {
    espeak-ng = espeak-ng';
  };

  meta = with lib; {
    description = "C++ library for converting text to phonemes for Piper";
    homepage = "https://github.com/rhasspy/piper-phonemize";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
