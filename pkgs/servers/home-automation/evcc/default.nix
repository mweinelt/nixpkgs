{ lib
, buildGoModule
, fetchFromGitHub
, fetchNpmDeps
, go
, git
, cacert
, mockgen
, nodejs
, npmHooks
, nixosTests
, stdenv
}:

buildGoModule rec {
  pname = "evcc";
  version = "0.106.3";

  src = fetchFromGitHub {
    owner = "evcc-io";
    repo = pname;
    rev = version;
    hash = "sha256-aR4LkNuoD62Ias8CLC7wtI8wSq7SXBW9XAtI6UMKPq0=";
  };

  vendorHash = "sha256-4eZz6opjdepkC7MTvLRLknvjbRmycIFKIJt8gwjiM9E=";

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-uQx8F5OXKm+fqx6hP6obVYTlQIYcJwtO52j6VQNo7Sk=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  overrideModAttrs = _: {
    nativeBuildInputs = [
      go
      git
      cacert
      mockgen
    ];

    preBuild = ''
      go install github.com/dmarkham/enumer
      export PATH="$GOPATH/bin:$PATH"
      go generate ./...
    '';

    postBuild = ''
      rm $GOPATH/bin/enumer
    '';
  };

  npmInstallFlags = [
    "--legacy-peer-deps"
  ];

  preBuild = ''
    make ui
  '';

  doCheck = !stdenv.isDarwin; # tries to bind to local network, doesn't work in darwin sandbox

  passthru.tests = {
    inherit (nixosTests) evcc;
  };

  meta = with lib; {
    description = "EV Charge Controller";
    homepage = "https://evcc.io";
    changelog = "https://github.com/andig/evcc/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
