{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  cargo,
  rustPlatform,
  rustc,

  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "sentry-ophio";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "ophio";
    rev = version;
    hash = "sha256-Tb7HFEPONxPIBg6eUmgzryszgAFpg55IV0mDuMZ+aeI=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-2NG8Kp6OWpBRn50N9ayvRfim0lAS0/JEF3jXuXX8ITs=";
  };

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "sentry_ophio" ];

  meta = {
    description = "";
    homepage = "https://github.com/getsentry/ophio";
    changelog = "https://github.com/getsentry/ophio/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
