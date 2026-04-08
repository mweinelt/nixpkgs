{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  diffutils,
  flex,
  python3Packages,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "check-sieve";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "dburkart";
    repo = "check-sieve";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dElVfLSVtlELleuxCScR6BGuLsJ+KRqcNA8y0lgrBfI=";
  };

  patches = [
    # https://github.com/dburkart/check-sieve/pull/111
    ./pr111.patch
  ];

  nativeBuildInputs = [
    bison
    flex
  ];

  enableParallelBuilding = true;

  nativeCheckInputs = [
    python3Packages.setuptools
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 check-sieve -t $out/bin
    runHook postInstall
  '';

  preCheck = ''
    substituteInPlace \
      test/AST/util.py \
      test/simulate/util.py \
      --replace-fail "/usr/bin/diff" "${lib.getExe' diffutils "diff"}"
  '';

  doCheck = true;

  meta = {
    description = "Syntax checker for mail sieves";
    mainProgram = "check-sieve";
    homepage = "https://github.com/dburkart/check-sieve";
    changelog = "https://github.com/dburkart/check-sieve/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ eilvelia ];
  };
})
