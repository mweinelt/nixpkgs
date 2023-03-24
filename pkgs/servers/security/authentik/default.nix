{ lib
, callPackage
, fetchFromGitHub
, python311

# tests
, redis
, postgresql
, postgresqlTestHook
}:

let
  python = python311.override {
    packageOverrides = self: super: {
      django = super.django_3;

      celery = super.celery.overridePythonAttrs (oldAttrs: {
        pytestFlagsArray = oldAttrs.pytestFlagsArray or [] ++ [
          "--deselect=t/unit/concurrency/test_prefork.py::test_AsynPool::test_gen_not_started"
        ];
      });

      kombu = super.kombu.overridePythonAttrs (_: {
        # pyro4 in nativeCheckInputs is disabled on python311
        doCheck = false;
      });

      moto = super.moto.overridePythonAttrs (_: {
        # tests are taking a very long time
        doCheck = false;
      });
    };
  };

  version = "2023.4.1";
  src = fetchFromGitHub {
    owner = "goauthentik";
    repo = "authentik";
    rev = "refs/tags/version/${version}";
    hash = "sha256-CyObDPsHDTxwxERFMD1sbFnlrt9wkwTIUXQjiEq+fdA=";
  };

  web = callPackage ./web.nix {
    inherit version src;
  };
in 

python.pkgs.buildPythonApplication rec {
  pname = "authentik";
  format = "pyproject";

  inherit version src;

  patches = [
    # disable failing tests
    ./tests.patch
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'psycopg2-binary' 'psycopg2' \
      --replace 'extras = ["secure"], ' ""

    # linting tool, that is not used during runtime
    sed -i "/codespell/d" pyproject.toml

    # we start authentik with systemd
    sed -i "/dumb-init/d" pyproject.toml

    # install web data
    cp --verbose --recursive --no-preserve=mode ${web}/* web/dist/

    # patch paths in default config
    substituteInPlace authentik/lib/default.yml \
      --replace "/blueprints" "./blueprints"

    substituteInPlace lifecycle/ak --replace \
      "-m manage" "${placeholder "out"}/bin/manage.py"

    patchShebangs lifecycle/ak manage.py
  '';

  nativeBuildInputs = with python.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python.pkgs; [
    celery
    channels
    channels-redis
    colorama
    dacite
    deepmerge
    defusedxml
    django
    django-filter
    django-guardian
    django-model-utils
    django-otp
    django-prometheus
    django-redis
    djangorestframework
    djangorestframework-guardian
    docker
    drf-spectacular
    duo-client
    facebook-sdk
    flower
    geoip2
    gunicorn
    kubernetes
    ldap3
    lxml
    opencontainers
    packaging
    paramiko
    psycopg2
    pycryptodome
    pydantic-scim
    pyjwt
    pyyaml
    requests-oauthlib
    sentry-sdk
    service-identity
    structlog
    swagger-spec-validator
    twilio
    twisted
    ua-parser
    urllib3
    uvicorn
    watchdog
    webauthn
    wsproto
    xmlsec
    zxcvbn
  ]
  ++ channels.optional-dependencies.daphne
  ++ opencontainers.optional-dependencies.reggie
  ++ urllib3.optional-dependencies.secure
  ++ uvicorn.optional-dependencies.standard;

  postInstall = ''
    cp -R lifecycle $out/${python.sitePackages}/
    cp -R manage.py $out/bin
  '';

  nativeCheckInputs = with python.pkgs; [
    importlib-metadata
    pyrad
    pytest
    pytest-django
    #pytest-randomly
    requests-mock
    selenium
    postgresql
    postgresqlTestHook
  ];

  env = {
    postgresqlEnableTCP = 1;
    postgresqlTestUserOptions = "CREATEDB LOGIN";

    PGUSER = "authentik";
    PGDATABASE = "authentik";

    DJANGO_SETTIGS_MODULE = "authelia.root.settings";
  
    AUTHENTIK_SECRET_KEY = "3AKyHIWN3reCItlNPsdATmNWKykGPzs4";
  };

  preCheck = ''
    # we don't provide docker or kubernetes for tests
    rm -v tests/integration/test*docker.py tests/integration/test*kubernetes.py

    # and as such we can"t support e2e tests either
    rm -rv tests/e2e/test_*.py

    ${redis}/bin/redis-server &
    REDIS_PID=$!
  '';

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} manage.py test
    runHook postCheck
  '';

  postCheck = ''
    kill $REDIS_PID
  '';

  passthru = {
    inherit python web;
    pythonPath = python.pkgs.mkPythonPath propagatedBuildInputs;
  };

  meta = with lib; {
    changelog = "https://github.com/goauthentik/authentik/releases/tag/version%2F${version}";
    downloadUrl = "https://github.com/goauthentik/authentik";
    description = "authentik is an open-source Identity Provider focused on flexibility and versatility";
    homepage = "https://goauthentik.io";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
