{ lib, python37Packages, fetchFromGitHub }:

python37Packages.buildPythonApplication rec {
  pname = "mycroft-precise";
  version = "unstable-2020-05-18";

  src = fetchFromGitHub {
    owner = "MycroftAI";
    repo = pname;
    rev = "ae0a9f9a05dfc60b894d2e42f484a564050d2be4";
    sha256 = "0fk7zx117svchxy2y5j64qhcbyx59hhdb6mnps3m24z2q46vlvzv";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "keras<=2.1.5" "keras" \
      --replace "numpy==1.16" "numpy" \
      --replace "tensorflow>=1.13,<1.14" "tensorflow" \
      --replace "typing" ""
  '';

  propagatedBuildInputs = with python37Packages; [
    attrs
    fitipy
    Keras
    precise-runner
    pyache
    prettyparse
    speechpy-fast
    sonopy
    numpy
    wavio
    tensorflow
    h5py
  ];

  checkInput = with python37Packages; [ pytest ];

  disabledTests = [ "conftest" ];

  meta = with lib; {
    description = "Mycroft Precise Wake Word Listener";
    homepage = "http://github.com/MycroftAI/mycroft-precise";
    licenses = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}

