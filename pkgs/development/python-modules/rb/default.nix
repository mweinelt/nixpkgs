{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  redis,
  redis-server,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "rb";
  version = "1.10.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = pname;
    rev = "refs/tags/${version}";
    hash = "sha256-6K4Y5TuIfHeJN6zPqQiXZYyED7kCb5IcKfSd70Kia7o=";
  };

  build-system = [ setuptools ];

  env.REDIS_VERSION = "==${redis.version}";

  dependencies = [
    redis
  ];

  nativeCheckInputs = [
    pytestCheckHook
    redis-server
  ];

  meta = with lib; {
    # https://github.com/getsentry/rb/issues/55
    broken = lib.versionAtLeast redis.version "5";
    description = "Routing and connection management for Redis in Python";
    homepage = "https://github.com/getsentry/rb";
    license = licenses.asl20;
    maintainers = lib.teams.sentry.members;
  };
}
