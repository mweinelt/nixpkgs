{ lib
, stdenv
, fetchFromGitHub

# build
, cmake
, pkg-config

# runtime
, espeak-ng
, onnxruntime
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
    rev = "15a25303fd856c67ae4ae774b04c116eead42ec1";
    hash = "sha256-tu3t+wShCoL1Ajnnzpsi1i1jHGxaqxa9a9+Uo8IPHAw=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    espeak-ng'
    onnxruntime
  ];

  ainstallPhase = ''
    runHook preInstall
    
    install -d $out/lib
    install ./libpiper_phonemize.so $out/lib

    install -d $dev/include/piper_phonemize
    install -D ../src/*.hpp $dev/include
    
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
