{ lib, buildPythonPackage, fetchFromGitHub
, pyaudio
, python
}:

buildPythonPackage rec {
  pname = "precise-runner";
  version = "unstable-2020-05-18";

  src = fetchFromGitHub {
    owner = "MycroftAI";
    repo = "mycroft-precise";
    rev = "ae0a9f9a05dfc60b894d2e42f484a564050d2be4";
    sha256 = "0fk7zx117svchxy2y5j64qhcbyx59hhdb6mnps3m24z2q46vlvzv";
  };

  sourceRoot = "source/runner";

  propagatedBuildInputs = [
    pyaudio
  ];

  # package has no serious tests set up
  doCheck = false;

  pythonImportsCheck = [ "precise_runner" ];

  meta = with lib; {
    description = "A simple to use, lightweight Python module for using Mycroft Precise";
    homepage = "https://github.com/MycroftAI/mycroft-precise";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
