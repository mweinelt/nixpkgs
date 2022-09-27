{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "email-reply-parser";
  version = "0.5.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "zapier";
    repo = "email-reply-parser";
    tag = "v${version}";
    hash = "sha256-UFyqYVvZMQ46Ph9h6Z21t1sDS4QTmjeJMFZjBiWOJNs=";
  };

  build-system = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "email_reply_parser"
  ];

  meta = with lib; {
    description = "Email reply parser library for Python";
    homepage = "https://github.com/zapier/email-reply-parser";
    license = licenses.mit;
    maintainers = lib.teams.sentry.members;
  };
}
