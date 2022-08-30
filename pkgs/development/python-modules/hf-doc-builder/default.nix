{ lib
, buildPythonPackage
, fetchFromGitHub

# propagates
, black
, GitPython
, gql
, nbformat
, packaging
, pyyaml
, requests
, tqdm

# tests
, pytest-xdist
, pytestCheckHook
, tokenizers
, torch
, transformers

}:

buildPythonPackage rec {
  pname = "hf-doc-builder";
  version = "0.4.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "doc-builder";
    rev = "refs/tags/v${version}";
    hash = "sha256-5KpeJeyWGDUSzQm0rAg4TtKkYrmRFwPtTEG+/WscFRM=";
  };

  propagatedBuildInputs = [
    black
    GitPython
    gql
    nbformat
    packaging
    pyyaml
    requests
    tqdm
  ];

  pythonImportsCheck = [
    "doc_builder"
  ];

  checkInputs = [
    pytest-xdist
    pytestCheckHook
    tokenizers
    torch
    transformers
  ];

  disabledTests = [
    # network access
    "test_resolve_links_in_text_other_docs"
    # AssertionError: 'List' != 'typing.List[str]'
    "test_get_type_name"
    # Expectation mismatch in renderer
    "test_convert_literalinclude"
  ];

  meta = with lib; {
    description = "Documentation builder for the Hugging Face repos";
    homepage = "https://github.com/huggingface/doc-builder";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
