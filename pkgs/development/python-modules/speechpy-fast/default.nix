{ lib, buildPythonPackage, fetchPypi
, scipy
, pytest
}:

buildPythonPackage rec {
  pname = "speechpy-fast";
  version = "2.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0xwm8xycsqr8kjqyg3b6ddv2nmvkpr0ai22lvd6k787wh5jsby1n";
  };

  propagatedBuildInputs = [ scipy ];

  # the git repository was deleted, only the pypi version without tests exists.
  doCheck = false;

  pythonImportsCheck = [
    "speechpy.feature"
    "speechpy.functions"
    "speechpy.processing"
  ];

  meta = with lib; {
    description = "A fork of the python package for extracting speech features";
    homepage = "https://github.com/matthewscholefield/speechpy";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
