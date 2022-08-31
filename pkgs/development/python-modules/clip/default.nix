{ lib
, buildPythonPackage
, fetchFromGitHub

# propagates
, ftfy
, regex
, tqdm
, torch
, torchvision

# tests
, numpy
, pillow
, pytestCheckHook
}:

buildPythonPackage {
  pname = "clip";
  version = "unstable-2022-07-27";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "openai";
    repo = "CLIP";
    rev = "d50d76daa670286dd6cacf3bcd80b5e4823fc8e1";
    hash = "sha256-GAitNBb5CzFVv2+Dky0VqSdrFIpKKtoAoyqeLoDaHO4=";
  };

  propagatedBuildInputs = [
    ftfy
    regex
    tqdm
    torch
    torchvision
  ];

  pythonImportsCheck = [
    "clip"
  ];

  doCheck = false; # all tests require network access

  checkInputs = [
    numpy
    pillow
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  meta = with lib; {
    description = "Contrastive Language-Image Pretraining";
    homepage = "https://github.com/openai/CLIP";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
