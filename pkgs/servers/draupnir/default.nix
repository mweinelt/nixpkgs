{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, nodejs
, yarn
, matrix-sdk-crypto-nodejs
, mkYarnPackage
, fetchYarnDeps
}:

# docs: https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/javascript.section.md#yarn2nix-javascript-yarn2nix

mkYarnPackage rec {
  pname = "draupnir";
  version = "1.85.1";
  # NOTE: Hard fork of Mjolnir.
  src = fetchFromGitHub {
    owner = "the-draupnir-project";
    repo = "Draupnir";
    rev = "v${version}";
    sha256 = "sha256-cXTkdvFYLsfoeVk5WAIABqw+oFynaMlBeBocXaJUO6A=";
  };

  nativeBuildInputs = [
    nodejs
    makeWrapper
    yarn
    matrix-sdk-crypto-nodejs
  ];
  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    # nix hash file yarn.lock
    hash = "sha256-j4xiEP54b7nn+bKkTUemwFNpA7s8DlsYnYX4KZgUhHU=";
  };
  yarnLock = src + "/yarn.lock";
  packageJSON = ./package.json;

  buildPhase = ''
      echo "Running preBuild"
      runHook preBuild
      export HOME=$(mktemp -d)
      echo "Building..."
      yarn --offline --verbose build
      # copy built modules to package...
      echo "Copying built matrix-sdk-crypto-nodejs modules to package..."
      cp -a ${matrix-sdk-crypto-nodejs}/lib/node_modules/* node_modules/
      echo "Adding version.txt..."
      mkdir -p deps/draupnir/
      echo "${version}-nix" > deps/draupnir/version.txt
      echo "Running postBuild..."
      runHook postBuild
    '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -a . $out/share/draupnir

    # include default configuration file
    cp $src/config $out/share/draupnir/ -rv

    makeWrapper ${nodejs}/bin/node $out/bin/draupnir \
      --add-flags $out/share/draupnir/deps/draupnir/lib/index.js

    runHook postInstall
  '';
  distPhase = "true";

  passthru = {
    #tests = {
    #  inherit (nixosTests) draupnir;
    #};
    updateScript = ./update.sh;
  };

  meta = with lib; {
    description = "A moderation tool for Matrix";
    homepage = "https://github.com/the-draupnir-project/Draupnir";
    longDescription = ''
      As an all-in-one moderation tool, it can protect your server from
      malicious invites, spam messages, and whatever else you don't want.
      In addition to server-level protection, Draupnir is great for communities
      wanting to protect their rooms without having to use their personal
      accounts for moderation.

      The bot by default includes support for bans, redactions, anti-spam,
      server ACLs, room directory changes, room alias transfers, account
      deactivation, room shutdown, and more.

      A Synapse module is also available to apply the same rulesets the bot
      uses across an entire homeserver.
    '';
    license = licenses.csl;
    maintainers = with maintainers; [ Rory ];
  };
}
