{ lib
, buildPythonPackage
, fetchFromGitHub

# propagates
, numpy
, torch
, tqdm

# tests
}:

buildPythonPackage rec {
  pname = "taming-transformers";
  version = "unstable-2022-01-13";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "CompVis";
    repo = pname;
    rev = "24268930bf1dce879235a7fddd0b2355b84d7ea6";
    hash = "sha256-kDChiuNh/lYO4M1Vj7fW3130kNl5wh+Os4MPBcaw1tM=";
  };

  propagatedBuildInputs = [
    numpy
    torch
    tqdm
  ];

  doCheck = false;

  meta = with lib; {
    description = "Taming Transformers for High-Resolution Image Synthesis";
    homepage = "https://github.com/CompVis/taming-transformers";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
