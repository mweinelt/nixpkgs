{ lib
, buildPythonPackage
, fetchFromGitHub

  # build-system
, setuptools

  # dependencies
, django

  # tests
, pytest-django
, pytest-mock
, pytestCheckHook
, psycopg
, postgresql
, postgresqlTestHook
}:

buildPythonPackage rec {
  pname = "django-pg-zero-downtime-migrations";
  version = "0.17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tbicr";
    repo = "django-pg-zero-downtime-migrations";
    tag = version;
    hash = "sha256-HklxOZh+IjOs8v/pdBspwTGTIgzaUPVmEnRkOTSAHpc=";
  };

  build-system = [ setuptools ];

  dependencies = [ django ];

  nativeCheckInputs = [
    postgresql
    postgresqlTestHook
    psycopg
    pytestCheckHook
    pytest-django
    pytest-mock
  ];

  env.postgresqlEnableTCP = true;

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.settings
  '';

  meta = with lib; {
    changelog = "https://github.com/tbicr/django-pg-zero-downtime-migrations/blob/${src.tag}/CHANGES.md";
    description = "Django postgresql backend that apply migrations with respect to database locks";
    homepage = "https://github.com/tbicr/django-pg-zero-downtime-migrations";
    license = licenses.mit;
    maintainers = lib.teams.sentry.members;
  };
}
