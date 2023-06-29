{ lib
, stdenv
, fetchFromGitHub

# build time
, cmake
, pkg-config

# runtime
, onnxruntime
, pcaudiolib
, piper-phonemize
, spdlog

# tests
, piper-train
}:

let
  pname = "piper";
  version = "1.0.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "piper";
    rev = "refs/tags/v${version}";
    hash = "sha256-4RcbKC3O4mnOEi7L4y5F384DTKp0jUplrM97Q708G18=";
  };

  sourceRoot = "source/src/cpp";

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    onnxruntime
    pcaudiolib
    piper-phonemize
    piper-phonemize.espeak-ng
    spdlog
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m 0755 piper $out/bin

    runHook postInstall
  '';

  passthru.tests = {
    inherit piper-train;
  };

  meta = with lib; {
    changelog = "https://github.com/rhasspy/piper/releases/tag/v${version}";
    description = "A fast, local neural text to speech system";
    homepage = "https://github.com/rhasspy/piper";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
