{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  grpcio
}:

buildPythonPackage rec {
  pname = "grpc-stubs";
  version = "1.53.0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "shabbyrobe";
    repo = "grpc-stubs";
    tag = version;
    hash = "sha256-an7xztaCqxOEmf74Rgb8q9u/WsojFYkBiwtLRa1qqBQ=";
  };

  build-system = [ setuptools ];

  dependencies = [ grpcio ];

  doCheck = false; # no tests

  meta = {
    description = "GRPC typing stubs for Python";
    homepage = "https://github.com/shabbyrobe/grpc-stubs";
    license = lib.licenses.mit;
    maintainers = lib.teams.sentry.members;
  };
}
