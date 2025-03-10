{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  cffi,
  pip,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "milksnake";
  version = "0.1.6";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AZj4kytOE2wpwNDUkP8brAP4LDp7Lub2ZuNoO2QxT9k=";
  };

  build-system = [ setuptools ];

  dependencies = [ cffi ];

  # tests rely on pip/venv
  doCheck = false;

  pythonImportsCheck = [ "milksnake" ];

  meta = with lib; {
    description = "Python library that extends setuptools for binary extensions";
    homepage = "https://github.com/getsentry/milksnake";
    license = licenses.asl20;
    maintainers = lib.teams.sentry.members ++ (with maintainers; [ matthiasbeyer ]);
  };
}
