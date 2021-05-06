{ lib
, buildPythonPackage
, fetchFromGitHub
, configparser
, crayons
, requests
, chromium
, firefox
, geckodriver
, pytestCheckHook
, selenium
}:

buildPythonPackage rec {
  pname = "webdriver-manager";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "SergeyPirogov";
    repo = "webdriver_manager";
    rev = "v.${version}";
    sha256 = "0p5q4d51gkyfsj1mrwdl0mgj2kh497jm8mx4wyrp30jp7ifb7hy8";
  };

  propagatedBuildInputs = [
    configparser
    crayons
    requests
  ];

  pythonImportChecks = [
    "webdriver_manager.firefox"
    "webdriver_manager.chrome"
  ];

  # requires network access and unfree browsers
  doCheck = false;

  meta = with lib; {
    description = "Library provides the way to automatically manage drivers for different browsers";
    homepage = "https://github.com/SergeyPirogov/webdriver_manager";
    maintainers = with maintainers; [ hexa ];
    licenses = licenses.asl20;
  };
}
