{
  lib,
  fetchFromGitHub,

  # backend
  php,

  # frontend
  stdenv,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  nodejs,
}:

let
  meta = {
    description = "strichliste is a tool to replace a tally sheet.";
    homepage = "https://www.strichliste.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    platforms = lib.platforms.all;
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "strichliste-frontend";
    version = "1.7.1";

    src = fetchFromGitHub {
      owner = "strichliste";
      repo = "strichliste-web-frontend";
      tag = "v${finalAttrs.version}";
      hash = "sha256-r9R//4XE85dkChLSu+Sn8Yo72dNZY8Z3yDHOiYIYjwg=";
    };

    yarnOfflineCache = fetchYarnDeps {
      yarnLock = finalAttrs.src + "/yarn.lock";
      hash = "sha256-NVQpXMiKVgFnAxLvl+BhFqXZU51D2CWfrVs5e/m4bMs=";
    };

    env.NODE_OPTIONS = "--openssl-legacy-provider";

    nativeBuildInputs = [
      nodejs
      yarnConfigHook
      yarnBuildHook
    ];

    installPhase = ''
      mkdir $out
      cp -R public/* $out/
    '';

    inherit meta;
  });
in

php.buildComposerProject2 (finalAttrs: {
  pname = "strichliste-backend";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "strichliste";
    repo = "strichliste-backend";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BlV7tynQKM2rEmnGjO4NuiutBVMDuT4di2oJjdz2suU=";
  };

  vendorHash = "sha256-Z+86UfMJczfK8z7sQBoDxeJnlbzq/28s66ifuXlJCms=";
  composerNoDev = true;
  composerStrictValidation = false;

  postInstall = ''
    mkdir $out/bin
    ln -s $out/share/php/strichliste-backend/bin/console $out/bin/strichliste-console
  '';

  inherit meta;

  passthru = {
    inherit frontend php;
  };
})
