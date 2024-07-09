{ buildNpmPackage
, src
, version
}:

buildNpmPackage {
  pname = "frigate-web";
  inherit version src;

  sourceRoot = "${src.name}/web";

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "--base=/BASE_PATH/" ""

    substituteInPlace \
      src/pages/Exports.tsx \
      src/components/card/{Export,Review}Card.tsx \
      src/components/player/PreviewThumbnailPlayer.tsx \
      src/components/timeline/EventSegment.tsx \
      src/views/system/StorageMetrics.tsx \
      --replace-fail "/media/frigate" "/var/lib/frigate" \
      --replace-quiet "/tmp/cache" "/var/cache/frigate"
  '';

  npmDepsHash = "sha256-gr4bh5FMjYu6/ejfrMShlApBdN4mZKBgtBbNHi/spKU=";

  installPhase = ''
    cp -rv dist/ $out
  '';
}
