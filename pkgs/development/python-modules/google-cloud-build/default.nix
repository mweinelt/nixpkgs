{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, google-api-core
, google-auth
, grpc-google-iam-v1
, proto-plus
, protobuf
, pytest-asyncio
, pytestCheckHook
, nix-update-script
}:

buildPythonPackage rec {
  pname = "google-cloud-functions";
  version = "3.31.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "google-cloud-build-v${version}";
    hash = "sha256-lLhmhk9m8hcpzPjVIG7j6XPEbxf9JoGffqFIls3+fJI=";
  };

  sourceRoot = "${src.name}/packages/google-cloud-build";

  build-system = [ setuptools ];

  pythonRelaxDeps = [ "protobuf" ];

  dependencies = [
    google-api-core
    google-auth
    grpc-google-iam-v1
    protobuf
    proto-plus
  ]
  ++ google-api-core.optional-dependencies.grpc;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  passthru = {
    # multi-package monorepo where the updater picks the wrong tag
    skipBulkUpdate = true;
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "google-cloud-functions-v(.+)"
      ];
    };
  };

  meta = with lib; {
    description = "Python Client for Cloud Build";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-cloud-build";
    license = licenses.asl20;
    maintainers = with maintainers; [ hexa ];
  };
}
