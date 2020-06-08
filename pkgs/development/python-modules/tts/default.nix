{ lib, pkgs, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "tts";
  version = "unstable-2020-06-06";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "TTS";
    rev = "1d3c0c88467d01e114063b54279693b464ac656a";
    sha256 = "1xjwlr0sw8l7rnp0acbs1v3s2l21cl12mxfhx2xk1nwi7v0brb21";
  };

  patches = [
    ./loosen-deps.patch
  ];

  propagatedBuildInputs = with python3Packages; [
    matplotlib
    scipy
    pytorch
    flask
    attrdict
    bokeh
    soundfile
    tqdm
    librosa
    unidecode
  ] ++ (with pkgs; [ 
    phonemizer
    tensorboardx
  ]);

  preBuild = ''
    export HOME=$TMPDIR
  '';

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/mozilla/TTS";
    description = "Deep learning for Text to Speech";
    license = licenses.mpl20;
    maintainers = with maintainers; [ hexa ];
  };
}
