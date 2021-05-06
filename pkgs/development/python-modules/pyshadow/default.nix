{ lib
, buildPythonPackage
, fetchFromGitHub
, multipledispatch
, selenium
, webdriver-manager
, python
}:

buildPythonPackage rec {
  pname = "pyshadow";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "sukgu";
    repo = pname;
    rev = "v${version}";
    sha256 = "0i6wsjj8ysl7mc85177ybkpfd97ss1p9y8wl8mcjay691ahhn8mn";
  };

  propagatedBuildInputs = [
    multipledispatch
    selenium
    webdriver-manager
  ];

  pythonImportsCheck = [
    "pyshadow.main"
  ];

  # Tests rely on Google Chrome, which is unfree
  doCheck = false;

  checkPhase = ''
    ${python.interpreter} -m unittest discover -s tests
  '';

  meta = with lib; {
    description = "Selenium plugin to manage multi level shadow DOM elements on web page";
    homepage = "https://github.com/sukgu/pyshadow";
    licenses = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
