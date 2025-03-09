{ lib
, buildPythonPackage
, fetchFromGitHub

# build-system
, cargo
, rustc
, rustPlatform
, setuptools-rust

# dependencies
, milksnake

# tests
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "sentry-relay";
  version = "0.9.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "relay";
    tag = "25.4.0";
    hash = "sha256-gXOyfgJdeSidsUyFqYaDshwfq9rCHWksg8Eapd8pe44=";
    fetchSubmodules = true;
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-m5Qw2GT6Er0rrCXotVsKWyzbuH/UIO/i8jY7DtHJtGs=";
  };

  build-system = [
    cargo
    setuptools-rust
    rustPlatform.cargoSetupHook
    rustc
  ];

  pypaBuildFlags = [ "py" ];

  dependencies = [ milksnake ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "sentry_relay" ];

  meta = with lib; {
    changelog = "https://github.com/getsentry/relay/releases/tag/${src.tag}";
    description = "Sentry event forwarding and ingestion service";
    homepage = "https://github.com/getsentry/relay";
    license = licenses.fsl11Asl20;
    maintainers = lib.teams.sentry.members;
  };
}
