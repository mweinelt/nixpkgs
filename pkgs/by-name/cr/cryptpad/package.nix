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

  npmFlagsArray = [
    "--loglevel=verbose"
  ];
}
