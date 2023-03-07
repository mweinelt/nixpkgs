{ lib
, buildPythonPackage
, fetchFromGitHub

# build-system
, autoPatchelfHook
, cmake
, cudaPackages
, pybind11

# propagates
, filelock
, lit
, torch

# tests
, numpy
, pytestCheckHook
, scipy
, 
}:

buildPythonPackage rec {
  pname = "triton";
  version = "2.0.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "openai";
    repo = "triton";
    rev = "refs/tags/v${version}";
    hash = "sha256-9GZzugab+Pdt74Dj6zjlEzjj4BcJ69rzMJmqcVMxsKU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    cmake
    pybind11
  ];

  postPatch = ''
    cd python

    substituteInPlace setup.py --replace \
      "self.base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))" \
      "self.base_dir = '$(realpath ..)'"
  '';

  preConfigure = ''
    export CMAKE_SOURCE_DIR=$(pwd)/..
  '';

  buildInputs = [
    torch
  ];

  propagatedBuildInputs = [  
    filelock
    lit
  ];

  nativeCheckInputs = [
    numpy
    pytestCheckHook
    scipy
  ];
}
