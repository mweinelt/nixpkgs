{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  absl-py,
  graphviz,
  libcst,
  typing-extensions,
  etils,
  cloudpickle,
  fiddle,
  flax,
  pytype,
  python,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "fiddle";
  version = "0.3.0";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-XQg9MpmkeYaDRVEzhabFVGFBvZIIbBXT3L+ACKkAddM=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    absl-py
    graphviz
    libcst
    typing-extensions
  ];

  optional-dependencies = {
    flags = [
      absl-py
      etils
    ];
  };

  enabledTests = [ "${placeholder "out"}/${python.sitePackages}/fiddle" ];

  nativeCheckInputs = [
    fiddle
    pytestCheckHook
    pytype
    seqio
    tensorflow
  ]
  ++ finalAttrs.passthru.optional-dependencies.testing;

  pythonImportsCheck = [
    "fiddle"
  ];

  meta = {
    description = "Fiddle: A Python-first configuration library";
    homepage = "https://pypi.org/project/fiddle";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
})
