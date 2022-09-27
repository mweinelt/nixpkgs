{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "petname";
  version = "2.6";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-mBwx73cjVqNzZA0bt8Z8EC4BWe2hRXjGehyZ1bNMnkw=";
  };

  # no tests
  doCheck = false;

  pythonImportsCheck = [
    "petname"
  ];

  meta = with lib; {
    description = "Generate human-readable, random object names";
    homepage = "https://launchpad.net/python-petname";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
