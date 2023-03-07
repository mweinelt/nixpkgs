{ lib
, fetchFromGitHub
, buildPythonPackage
, substituteAll

# runtime
, ffmpeg

# propagates
, ffmpeg-python
, more-itertools
, numba
, numpy
, torch
, tqdm
, transformers
, triton

# tests
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "whisper";
  version = "20230306";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "openai";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-j1X4e1mZnSWxZT1bdxt72mrZZlQGxjoxabJi3SdGrUY=";
  };

  patches = [
    (substituteAll {
      src = ./ffmpeg-path.patch;
      inherit ffmpeg;
    })
  ];

  propagatedBuildInputs = [
    ffmpeg-python
    more-itertools
    numba
    numpy
    torch
    tqdm
    transformers
    triton
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  disabledTests = [
    # requires network access to download models
    "test_transcribe"
  ];

  meta = with lib; {
    description = "General-purpose speech recognition model";
    homepage = "https://github.com/openai/whisper";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}

