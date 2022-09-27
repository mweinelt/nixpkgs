{ lib
, fetchFromGitHub
, fetchPypi
, python3
}:

let
  pname = "sentry";
  version = "25.2.0";

  python = python3.override {
    packageOverrides = self: super: {
      # for compat with rb 1.10.0
      redis = super.redis.overridePythonAttrs rec {
        version = "4.6.0";

        src = fetchPypi {
          pname = "redis";
          inherit version;
          hash = "sha256-WF3FFrnrBCphnvCjnD19Vf6BvbTfCaUsnN3g0Hvxqn0=";
        };
      };

      sentry-forked-email-reply-parser = super.email-reply-parser.overridePythonAttrs rec {
        pname = "sentry-forked-email-reply-parser";
        version = "0.5.12-1";

        src = fetchFromGitHub {
          owner = "getsentry";
          repo = "sentry-forked-email-reply-parser";
          tag = version;
          hash = "sha256-aQtLN7ofIhzJDlBvUxQP2oMT4eZU8t4U9+xLhM1L9eg=";
        };
      };

      sentry-sdk = super.sentry-sdk_2;
    };
  };
in
python.pkgs.buildPythonApplication {
  inherit pname version;
  format = "other";

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "sentry";
    tag = version;
    hash = "sha256-uCJXW47WLJn6RtvunOoVNidica9ber8B/9hD6yl9n9M=";
  };

  dependencies = with python.pkgs; [
    beautifulsoup4
    boto3
    botocore
    brotli
    cachetools
    celery
    click
    confluent-kafka
    cronsim
    cryptography
    cssselect
    datadog
    django
    django-crispy-forms
    django-csp
    django-pg-zero-downtime-migrations
    djangorestframework
    drf-spectacular
    fido2
    google-api-core
    googleapis-common-protos
    google-auth
    google-cloud-bigtable
    google-cloud-build
    google-cloud-core
    google-cloud-functions
    google-cloud-kms
    google-cloud-pubsub
    google-cloud-spanner
    google-cloud-storage
    google-crc32c
    grpc-google-iam-v1
    grpcio
    hiredis
    isodate
    jsonschema
    lxml
    maxminddb
    mistune
    mmh3
    msgpack
    openai
    orjson
    packaging
    parsimonious
    petname
    phonenumberslite
    pillow
    progressbar2
    protobuf
    proto-plus
    psutil
    psycopg2-binary
    pydantic
    pyjwt
    pymemcache
    python3-saml
    python-dateutil
    python-rapidjson
    python-u2flib-server
    #pyuwsgi
    pyyaml
    rb
    redis
    redis-py-cluster
    requests
    requests-oauthlib
    rfc3339-validator
    rfc3986-validator
    sentry-arroyo
    sentry-forked-email-reply-parser
    sentry-kafka-schemas
    sentry-ophio
    sentry-protos
    sentry-redis-tools
    sentry-relay
    sentry-sdk
    sentry-usage-accountant
    simplejson
    slack-sdk
    snuba-sdk
    sqlparse
    statsd
    structlog
    symbolic
    tiktoken
    tldextract
    tornado
    typing-extensions
    ua-parser
    unidiff
    urllib3
    zstandard
  ]
  ++ urllib3.optional-dependencies.brotli
  ++ sentry-sdk.optional-dependencies.http2;

  checkInputs = with python.pkgs; [

  ];

  passthru = {
    inherit python;
  };

  meta = with lib; {
    changelog = "https://github.com/getsentry/sentry/releases/tag/${version}";
    description = "Cross-platform application monitoring, with a focus on error reporting";
    homepage = "https://github.com/getsentry/sentry";
    license = licenses.bsl11;
    maintainers = with maintainers; [ hexa ];
  };
}
