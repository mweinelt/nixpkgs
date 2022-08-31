{ lib
, buildPythonPackage
, fetchFromGitHub

# propagates
, filelock
, huggingface-hub
, importlib-metadata
, numpy
, pillow
, regex
, requests
, torch

# tests
, pytest-timeout
, pytest-xdist
, pytestCheckHook

}:

buildPythonPackage rec {
  pname = "diffusers";
  version = "0.2.4";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-ZrbgGfxIh8eUXDcZdOEdg2I6ZrXjz4QpGprQVSWTjI8=";
  };

  propagatedBuildInputs = [
    filelock
    huggingface-hub
    importlib-metadata
    numpy
    pillow
    regex
    requests
    torch
  ];

  pythonImportsCheck = [
    "diffusers"
  ];

  checkInputs = [
    pytest-timeout
    pytest-xdist
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  disabledTests = [
    # requires network access
    "test_from_pretrained_hub"
    "test_output_pretrained"
    "test_output_pretrained_ve_large"
    "test_output_pretrained_ve_mid"

    # too much noise
    "test_full_loop_no_noise"
  ];

  meta = with lib; {
    changelog = "https://github.com/huggingface/diffusers/releases/tag/v${version}";
    description = "State-of-the-art diffusion models for image and audio generation in PyTorch";
    homepage = "https://github.com/huggingface/diffusers";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
