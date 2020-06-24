{ lib, buildPythonPackage, fetchFromGitHub
, numpy
}:

buildPythonPackage rec {
  pname = "wavio";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "WarrenWeckesser";
    repo = pname;
    rev = "v${version}";
    sha256 = "0hq6ip4yqxlpp85dvaf1hqzvfd1x00ghclvzgk99j84i6sfdjkc3";
  };

  propagatedBuildInputs = [
    numpy
  ];

  checkPhase = ''
    python tests/test_wavio.py
  '';

  meta = with lib; {
    description = "A Python module for reading and writing WAV files using numpy arrays";
    homepage = "https://github.com/WarrenWeckesser/wavio";
    license = licenses.bsd3;
    maintainers = with maintainers; [ hexa ];
  };
}
