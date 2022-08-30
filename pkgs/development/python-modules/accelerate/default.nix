{ lib
, buildPythonPackage
, fetchFromGitHub
, makeWrapper

# propagates
, numpy
, packaging
, psutil
, torch
, pyyaml
, rich

# optional
, sagemaker

# tests
, parameterized
, pytest-subtests
, pytest-xdist
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "accelerate";
  version = "0.12.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "accelerate";
    rev = "refs/tags/v${version}";
    hash = "sha256-W0tFFX+ryHUK/hRHFXY3YfrHejfPwwk5xKomwSCJJvM=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = [
    numpy
    packaging
    psutil
    torch
    pyyaml
    rich
  ];

  passthru.optional-dependencies.sagemaker = [
    sagemaker
  ];

  postInstall = ''
    for program in $out/bin/*; do
      wrapProgram "$program" \
        --prefix PYTHONPATH : "$PYTHONPATH"
    done
  '';

  doCheck = false;

  checkInputs = [
    parameterized
    pytest-subtests
    pytest-xdist
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "accelerate"
  ];

  meta = with lib; {
    description = "A simple way to train and use PyTorch models with multi-GPU, TPU, mixed-precision";
    license = licenses.asl20;
    homepage = "https://github.com/huggingface/accelerate";
    maintainers = with maintainers; [ hexa ];
  };
}
