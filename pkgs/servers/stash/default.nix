{ lib
, buildGoModule
, fetchFromGitHub
, fetchYarnDeps

# ui
, prefetch-yarn-deps
, nodejs-slim
, nodejs
}:

let
  pname = "stash";
  version = "0.22.1";

  src = fetchFromGitHub {
    owner = "stashapp";
    repo = "stash";
    rev = "refs/tags/v${version}";
    hash = "sha256-QtAZ9+ujqHm4lMGOf4tiBYio/LKAeBc6WPkfDH2mKOE=";
  };

  yarnOfflineCache = fetchYarnDeps {
    name = "${pname}-${version}-yarn-deps";
    yarnLock = "${src}/ui/v2.5/yarn.lock";
    hash = "sha256-qP/9EK7rZQ7Wn0WQmrWcJhiD73S5I6TnSfYE0fJqFsI=";
  };
in

buildGoModule {
  inherit pname version src;

  vendorHash = null;

  nativeBuildInputs = [
    prefetch-yarn-deps
    nodejs-slim
    nodejs.pkgs.yarn
  ];

  postPatch = ''
    export HOME=$TMPDIR
    pushd ui/v2.5
    yarn config --offline set yarn-offline-mirror "${yarnOfflineCache}"
    fixup-yarn-lock yarn.lock
    yarn install --frozen-lockfile --offline --no-progress --non-interactive --ignore-scripts
    popd
  '';

  preBuild = ''
    pushd ui/v2.5
    yarn --offline build
    popd
  '';

  ldFlags = [
    "-s"
    "-w"
    "-x github.com/stashapp/stash/internal/build.githash=${src.rev}"
    "-x github.com/stashapp/stash/internal/build.version=${version}"
  ];

  CGO_ENABLED = 1;

  meta = with lib; {
    description = "An organizer for your porn";
    homepage = "https://stashapp.cc/";
    downloadPage = "https://github.com/stashapp/stash";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ hexa ];
  };
}