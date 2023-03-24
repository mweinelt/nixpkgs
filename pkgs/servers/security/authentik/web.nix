{ buildNpmPackage
, version
, src
}:

buildNpmPackage {
  pname = "authentik-web";
  inherit version src;

  sourceRoot = "source/web";

  npmDepsHash = "sha256-1053Ubv3kweZFVRAteaPIGFFkzmTpo448jahQyzEYuw=";

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -R dist/* $out/
    runHook postInstall
  '';
}
