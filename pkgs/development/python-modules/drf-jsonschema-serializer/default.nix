{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # dependencies
  django,
  djangorestframework,
  jsonschema,

  # optional-dependencies
  fqdn,
  idna,
  isoduration,
  jsonpointer,
  rfc3339-validator,
  rfc3987,
  uri-template,
  webcolors,
  django-stubs,
  djangorestframework-stubs,

  # tests
  pytestCheckHook,
  pytest-django,
}:

buildPythonPackage rec {
  pname = "drf-jsonschema-serializer";
  version = "3.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "maykinmedia";
    repo = "drf-jsonschema-serializer";
    rev = version;
    hash = "sha256-+Kow1JmSJKOo/AMLx08CBcaq7NwY2HpasTIZ3ZT2jxM=";
  };

  postPatch = ''
    echo "REST_FRAMEWORK = {}" >> testapp/settings.py
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    django
    djangorestframework
    jsonschema
  ];

  optional-dependencies = {
    all-format-validators = [
      fqdn
      idna
      isoduration
      jsonpointer
      rfc3339-validator
      rfc3987
      uri-template
      webcolors
    ];
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
  ] ++ lib.flatten (lib.attrValues optional-dependencies);

  env.DJANGO_SETTINGS_MODULE = "testapp.settings";

  meta = {
    description = "JSON schema integration for Django REST Framework";
    homepage = "https://github.com/maykinmedia/drf-jsonschema-serializer";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
