{ lib, buildPythonPackage, fetchPypi
, portalocker
, networkx
, scikitlearn
, scikit-optimize
}:

buildPythonPackage rec {
  pname = "bbopt";
  version = "1.1.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1bsf487wsgvsi3d2c2qw3gah9gzsy7dajy2p1i18rzhr009wpshm";
  };

  propagatedBuildInputs = [
    portalocker
    networkx
    scikit-optimize
  ];

  checkInputs = [
    scikitlearn
  ];

  meta = with lib; {
    description = "The easiest hyperparameter optimization you'll ever do";
    homepage = "https://github.com/evhub/bbopt";
    licenses = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
