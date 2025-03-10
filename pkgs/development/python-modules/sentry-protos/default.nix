{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  grpc-stubs,
  grpcio-tools,
  mypy-protobuf,
}:

buildPythonPackage rec {
  pname = "sentry-protos";
  version = "0.1.63";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "sentry-protos";
    tag = version;
    hash = "sha256-aDKeAl5f0UdP4S62jEyux7JhVLDfW4q9DbEWwMFkwl0=";
  };

  build-systeem = [ setuptools ];

  nativeBuildInputs = [
    grpcio-tools
    mypy-protobuf
  ];

  dependencies = [
    grpc-stubs
  ];

  env.SENTRY_PROTOS_BUILD_UNSTABLE = "1";

  preBuild = ''
    python py/generate.py

    cd py
  '';

  meta = {
    description = "Protobuf schema, and service stub libraries repo for internal sentry services";
    homepage = "https://github.com/getsentry/sentry-protos";
    changelog = "https://github.com/getsentry/sentry-protos/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.fsl11Asl20;
    maintainers = lib.teams.sentry.members;
    mainProgram = "sentry-protos";
    platforms = lib.platforms.all;
  };
}
