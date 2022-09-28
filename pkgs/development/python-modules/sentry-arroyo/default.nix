{ lib
, buildPythonPackage
, fetchFromGitHub
, confluent-kafka
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "sentry-arroyo";
  version = "1.0.4";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "arroyo";
    rev = "refs/tags/${version}";
    hash = "sha256-P6aCqOIfiH/ol62Up4Lnj5krsohEhhJK1B462onJ+vk=";
  };

  propagatedBuildInputs = [
    confluent-kafka
  ];

  checkInputs = [
    pytestCheckHook
  ];

  disabledTestPaths = [
    # requires a kafka instance
    "tests/backends/test_kafka.py"
  ];

  pythonImportsCheck = [
    "arroyo"
  ];

  meta = with lib; {
    description = "Python library for working with streaming data";
    homepage = "https://github.com/getsentry/arroyo";
    license = licenses.asl20;
    maintainers = with maintainers; [ mweinelt ];
  };
}
