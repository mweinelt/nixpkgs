{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  ninja,
  pybind11,
  setuptools,
  attrs,
  immutabledict,
  importlab,
  jinja2,
  libcst,
  msgspec,
  networkx,
  pycnite,
  pydot,
  tabulate,
  toml,
  typing-extensions,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytype";
  version = "2024.10.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "google";
    repo = "pytype";
    tag = finalAttrs.version;
    hash = "sha256-dGRJx5QIj8ytak9miv67gRc371wdSC2VNACc+IciCNQ=";
  };

  build-system = [
    ninja
    pybind11
    setuptools
  ];

  dependencies = [
    attrs
    immutabledict
    importlab
    jinja2
    libcst
    msgspec
    networkx
    ninja
    pycnite
    pydot
    tabulate
    toml
    typing-extensions
  ];

  pythonImportsCheck = [
    "pytype"
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = {
    description = "A static type analyzer for Python code";
    homepage = "https://github.com/google/pytype";
    changelog = "https://github.com/google/pytype/blob/${finalAttrs.src.tag}/CHANGELOG";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
