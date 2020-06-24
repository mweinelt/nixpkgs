{ lib, buildPythonPackage, fetchPypi, isPy27
, numpy
}:

buildPythonPackage rec {
  pname = "pyache";
  version = "0.1.0";
  disabled = isPy27;

  src = fetchPypi {
    inherit pname version;
    sha256 = "1m6ipm1684rllaak0q23jn0436mjwxxzcyfypirxrj702ivi7dgn";
  };

  propagatedBuildInputs = [ numpy ];

  # package has no tests
  doCheck = false;

  pythonImportsCheck = [ "pyache" ];

  meta = with lib; {
    description = "Python numpy caching library";
    homepage = "http://github.com/MatthewScholefield/pyache";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
