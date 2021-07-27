{ pkgs
, lib
, stdenv
, buildGo118Module
, fetchFromGitHub
, mockgen
, nixosTests

# updateScript
, coreutils
, curl
, jq
, git
, gnused
, nix-prefetch-git
, nix-update
, nodePackages
}:

let
  nodejs = pkgs.nodejs-14_x;
  nodeEnv = import ../../../development/node-packages/node-env.nix {
    inherit (pkgs) stdenv lib python2 runCommand writeTextFile writeShellScript;
    inherit pkgs nodejs;
    libtool = if stdenv.isDarwin then pkgs.darwin.cctools else null;
  };
  evccNodePackages = import ./node-packages.nix {
    inherit (pkgs) fetchurl nix-gitignore stdenv lib fetchgit;
    inherit nodeEnv;
  };

  srcJSON = lib.importJSON ./src.json;
  src = fetchFromGitHub {
    owner = "andig";
    repo = "evcc";
    inherit (srcJSON) rev sha256;
  };

  nodeDependencies = (evccNodePackages.shell.override (old: {
    inherit src;
  })).nodeDependencies;
in
buildGo118Module rec {
  pname = "evcc";
  version = "0.104.2";

  inherit src;

  vendorSha256 = "sha256-tkGKKtPUTGlUpq5V9QzqON9LotAlUeeV2EwmdZ++VNk=";

  nativeBuildInputs = [
    mockgen
    nodejs
  ];

  tags = [
    "release"
  ];

  ldflags = [
    "-X github.com/evcc-io/evcc/server.Version=${version}"
    "-X github.com/evcc-io/evcc/server.Commit=${srcJSON.rev}"
    "-s"
    "-w"
  ];

  preBuild = ''
    (
      ln -s ${nodeDependencies}/lib/node_modules ./node_modules
      export PATH="${nodeDependencies}/bin:$PATH"

      npm run build
    )

    go install github.com/dmarkham/enumer
    export PATH="$GOPATH/bin:$PATH"

    go generate ./...
  '';

  postBuild = ''
    rm $GOPATH/bin/enumer
  '';

  # Tries to connect to a bunch of ev charger units over network/bluetooth
  doCheck = false;

  passthru.updateScript = pkgs.writeShellScript "evcc-updater" ''
    export PATH=${lib.makeBinPath [
      coreutils
      curl
      git
      gnused
      jq
      nix-prefetch-git
      nix-update
      nodePackages.node2nix
    ]}

    cd pkgs/servers/home-automation/evcc

    latest=$(curl ''${GITHUB_TOKEN:+"-u \":$GITHUB_TOKEN\""} https://api.github.com/repos/evcc-io/evcc/releases/latest | jq -r '.name')

    nix-prefetch-git https://github.com/evcc-io/evcc "$latest" > ${toString ./src.json }
    srcpath=$(jq '.path' -r src.json)

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' exit

    # fix urls in package-lock that node2nix can't handle
    sed 's/tgz?[^"]\+/tgz/' "$srcpath/package-lock.json" > "$tmp/package-lock.json"

    # add missing version attribute
    jq < "$srcpath"/package.json > "$tmp"/package.json \
      --arg version "$latest" \
      '.version |= $version'

    node2nix \
      --nodejs-14 \
      --input "$tmp/package.json" \
      --lock "$tmp/package-lock.json" \
      --no-copy-node-env \
      --development \
      --composition /dev/null \
      --output ./node-packages.nix

    nix-update -f ../../../../default.nix evcc --version "$latest"
  '';

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
