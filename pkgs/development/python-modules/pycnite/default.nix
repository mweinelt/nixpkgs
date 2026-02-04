{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycnite";
  version = "2024.7.31";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "google";
    repo = "pycnite";
    rev = "85915c41102bcb66a2633dbbe35e9b4940861ee7";
    hash = "sha256-P36EYjwKC4RTvFzmu20+vzI/LbOJPrdXWDIikjUaeMo=";
  };

  build-system = [
    setuptools
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "pycnite"
  ];

  meta = {
    description = "Python bytecode utilities";
    homepage = "github.com/google/pycnite";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
