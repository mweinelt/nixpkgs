{ lib
, buildNpmPackage
, fetchFromGitHub
}:

let
  pname = "cryptpad";
  version = "5.6.0";
in
buildNpmPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "cryptpad";
    repo = "cryptpad";
    rev = version;
    hash = "sha256-A3tkXt4eAeg1lobCliGd2PghpkFG5CNYWnquGESx/zo=";
  };

  makeCacheWritable = true;

  npmDepsHash = "sha256-tQUsI5Oz3rkAlxJ1LpolJNqZfKUGKUYSgtuCTzHRcW4=";

  meta = with lib; {
    changelog = "https://github.com/cryptpad/cryptpad/releases/tag/${version}";
    description = "Collaborative office suite, end-to-end encrypted and open-source";
    downloadPage = "https://github.com/cryptpad/cryptpad";
    homepage = "https://cryptpad.org";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ hexa ];
  };
}
