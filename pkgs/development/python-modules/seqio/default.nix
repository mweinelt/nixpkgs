{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "seqio";
  version = "0-unstable-2026-01-14";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "google";
    repo = "seqio";
    rev = "db78942f10f9937ed42d42adf94c7f669b36fc84";
    hash = "sha256-MjAmBGXFZvF+Kb6OEeeLKazx+TGl8LjsS4nUqX0IcBo=";
  };

  build-system = [
    setuptools
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "seqio"
  ];

  meta = {
    description = "Task-based datasets, preprocessing, and evaluation for sequence models";
    homepage = "https://github.com/google/seqio";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
