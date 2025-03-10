{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  cargo,
  rustPlatform,
  rustc,
  setuptools,

  # dependencies
  python-rapidjson,
  pyyaml,
  typing-extensions,
  fastjsonschema,
  msgpack,
  sentry-protos,

  # tests
  jsonschema,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "sentry-kafka-schemas";
  version = "1.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "sentry-kafka-schemas";
    rev = version;
    hash = "sha256-RSYUxzI0y+yCX8ONRCP1pbjrw07KuXbkbYJkvIn9mlw=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustc
    setuptools
  ];

  pythonRelaxDeps = [ "python-rapidjson" ];

  dependencies = [
    python-rapidjson
    pyyaml
    typing-extensions
    fastjsonschema
    msgpack
    sentry-protos
  ];

  nativeCheckInputs = [
    jsonschema
    pytestCheckHook
  ];

  pythonImportsCheck = [ "sentry_kafka_schemas" ];

  meta = {
    description = "Kafka topic and schema registry for Sentry";
    homepage = "https://github.com/getsentry/sentry-kafka-schemas";
    changelog = "https://github.com/getsentry/sentry-kafka-schemas/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.fsl11Asl20;
    maintainers = lib.teams.sentry.members;
  };
}
