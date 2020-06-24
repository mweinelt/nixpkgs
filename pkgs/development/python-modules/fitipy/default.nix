{ lib, buildPythonPackage, fetchPypi, isPy27 }:

buildPythonPackage rec {
  pname = "fitipy";
  version = "0.1.2";
  disabled = isPy27;

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ygra7xrjdicyiljzrcxqnzxskfh9lnm9r4ka3sqb9hpphsmqd92";
  };

  # package has no tests
  doCheck = false;

  pythonImportsCheck = [ "fitipy" ];

  meta = with lib; {
    description = "A simple filesystem interface";
    homepage = "http://github.com/MatthewScholefield/fitipy";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
