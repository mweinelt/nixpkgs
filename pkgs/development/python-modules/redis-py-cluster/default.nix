{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  redis,
  hiredis,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "redis-py-cluster";
  version = "2.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Grokzen";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-nwik+LW66dr2uczCDaGGk5y2FXPy0nl8SqDWT6oTmpo=";
  };

  build-system = [ setuptools ];

  pythonRelaxDeps = [ "redis" ];

  dependencies = [ redis ];

  optional-dependencies.hiredis = [
    hiredis
  ];

  # ModuleNotFoundError: No module named 'redis._compat'
  doCheck = lib.versionOlder redis.version "4";

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = with lib; {
    broken = lib.versionAtLeast redis.version "5";
    description = "Python cluster client for the official redis cluster. Redis 3.0+.";
    homepage = "https://github.com/Grokzen/redis-py-cluster";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
