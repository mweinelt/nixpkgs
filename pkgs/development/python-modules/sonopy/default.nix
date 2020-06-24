{ lib, buildPythonPackage, fetchPypi
, scipy
}:

buildPythonPackage rec {
  pname = "sonopy";
  version = "0.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0i8chwx26b84i4p8xpqvixfalm4532hz72njnhxiiwgmbc2jrkfp";
  };

  propagatedBuildInputs = [
    scipy
  ];

  # package has no tests
  doCheck = false;

  pythonImportsCheck = [ "sonopy" ];

  meta = with lib; {
    description = "A simple audio feature extraction library";
    homepage = "http://github.com/MatthewScholefield/sonopy";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
