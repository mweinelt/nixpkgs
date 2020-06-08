{ lib, pkgs, python3Packages, fetchFromGitHub, glibcLocales }:

python3Packages.buildPythonApplication rec {
  pname = "tensorboardX";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "lanpa";
    repo = pname;
    rev = "v${version}";
    sha256 = "0qqalq0fhbx0wnd8wdwhyhkkv2brvj9qbk3373vk3wjxbribf5c7";
  };

  propagatedBuildInputs = with python3Packages; [
    crc32c
    matplotlib
    numpy
    protobuf
  ];

  checkInputs = with python3Packages; [
    pytest
    pytorch
    boto3
    moto
  ] ++ (with pkgs; [
    visdom
    wget
  ]);

  doCheck = false;

  meta = {
    description = "tensorboard for pytorch (and chainer, mxnet, numpy, ...)";
    homepage = "https://tensorboardx.readthedocs.io";
    license = lib.licenses.mit;
  };
}

