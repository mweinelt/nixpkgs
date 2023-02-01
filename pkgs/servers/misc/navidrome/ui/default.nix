{ buildNpmPackage
, nodejs
, src
, version
}:

buildNpmPackage {
  pname = "navidrome-ui";
  inherit version;

  src = "${src}/ui";

  npmDepsHash = "sha256-QpNvMsALcDcMJOdY7e4YLZvHabSFjWve9C9UFDMOoYU=";

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -rv ./build/* $out/
    runHook postInstall
  '';
}
