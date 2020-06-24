{ lib, buildPythonPackage, fetchPypi
, pytest
}:

buildPythonPackage rec {
  pname = "prettyparse";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1z0lvqsy6xhr8n475argy70mv8y68203mcaxzb1lh40n8js6xsq2";
  };

  checkInputs = [ pytest ];

  checkPhase = ''
    pytest test
  '';

  meta = with lib; {
    description = "A clean, simple way to create Python argument parsers";
    homepage = "https://github.com/MatthewScholefield/prettyparse";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
