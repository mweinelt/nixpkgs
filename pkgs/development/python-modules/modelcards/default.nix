{ lib
, buildPythonPackage
, fetchFromGitHub

# propgates
, huggingface-hub
, jinja2
, pyyaml

# tests
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "modelcards";
  version = "0.1.6";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "nateraw";
    repo = "modelcards";
    rev = "refs/tags/v${version}";
    hash = "sha256-fuOui9MKYrbIGwiCu/iZ2n1juaY5RQaOI0D985ImqIQ=";
  };

  propagatedBuildInputs = [
    huggingface-hub
    jinja2
    pyyaml
  ];

  pythonImportsCheck = [
    "modelcards"
  ];

  checkInputs = [
    pytestCheckHook
  ];

  disabledTests = [
    # network access
    "test_validate_modelcard"
    "test_push_to_hub"
    "test_push_and_create_pr"
  ];

  meta = with lib; {
    changelog = "https://github.com/nateraw/modelcards/releases/tag/v${version}";
    description = "Utility to create, edit, and publish model cards on the Hugging Face Hub";
    homepage = "https://github.com/nateraw/modelcards";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
