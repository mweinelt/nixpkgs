{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, flit-core

# tests
, chex
, pytest-subtests
, pytest-xdist
, pytestCheckHook
, yapf

# optional
, jupyter
# TODO: , mediapy
, numpy
, importlib-resources
, typing-extensions
, zipp
, absl-py
, tqdm
, dm-tree
, jax
, tensorflow
}:

buildPythonPackage rec {
  pname = "etils";
  version = "0.6.0";
  format = "pyproject";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZnckEFGDXQ2xHElHvK2Tj1e1HqECKQYk+JLx5OUbcOU=";
  };

  nativeBuildInputs = [
    flit-core
  ];

  passthru.optional-dependencies = rec {
    array-types = [
    ]
    ++ enp;

    ecolab = [
      jupyter
      numpy
      # TODO: mediapy
    ]
    ++ enp
    ++ epy;

    edc = [
    ]
    ++ epy;

    enp = [
      numpy
    ]
    ++ epy;

    epath = [
      importlib-resources
      typing-extensions
      zipp
    ]
    ++ epy;

    epy = [
      typing-extensions
    ];

    etqdm = [
      absl-py
      tqdm
    ]
    ++ epy;

    etree = [
    ]
    ++ array-types
    ++ epy
    ++ enp
    ++ etqdm;

    etree-dm = [
      dm-tree
    ]
    ++ etree;

    etree-jax = [
      jax
    ]
    ++ etree;

    etree-tf = [
      tensorflow
      etree
    ]
    ++ etree;

    all = [
    ]
    ++ array-types
    ++ ecolab
    ++ edc
    ++ enp
    ++ epath
    ++ epy
    ++ etqdm
    ++ etree
    ++ etree-dm
    ++ etree-jax
    ++ etree-tf;
  };

  pythonImportsCheck = [
    "etils"
  ];

  doCheck = false;

  checkInputs = [
    chex
    pytest-subtests
    pytest-xdist
    pytestCheckHook
    yapf
  ]
  ++ passthru.optional-dependencies.all;

  meta = with lib; {
    description = "Collection of eclectic utils for python";
    homepage = "https://github.com/google/etils";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
