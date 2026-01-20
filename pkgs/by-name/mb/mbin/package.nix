{
  lib,
  fetchFromGitHub,

  # backend
  php84,

  # frontend
  fetchNpmDeps,
  nodejs,
  npmHooks,

  # config is a build time requirement
  env ? null
}:

assert lib.assertMsg (
  env != null
) "mbin: building requires the configuration to be passed as a file via the `env` argument";

let
  php = php84.buildEnv {
    extensions = {
      enabled,
      all,
    }:
      enabled ++ (with all; [
        amqp
        redis
      ]);
  };
in

php.buildComposerProject2 (finalAttrs: {
  pname = "mbin";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "MbinOrg";
    repo = "mbin";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4Q9XxwY+rM2z6PJx1KdG5qGNxBHJjycHXX5GM6IU0E8=";
  };

  postPatch = ''
    ln -s ${env} .env
  '';

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-S3JXKGax1/3aiCqv+1E+AnHA5/HASwdZAD1sKtRo+c0=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  npmBuildScript = "build";

  composerNoDev = true;
  vendorHash = "sha256-s2tXAqVkbR069cL+mFL2dQ9ww+/OKJOi9QC3nT+S03c=";

  postBuild = ''
    npm run build
    rm -rf node_modules
  '';

  passthru = {
    inherit php;
  };

  meta = {
    description = "Federated content aggregator, voting, discussion and microblogging platform";
    homepage = "https://github.com/MbinOrg/mbin";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ hexa ];
    platforms = lib.platforms.all;
  };
})
