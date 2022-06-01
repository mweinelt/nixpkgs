{ lib
, stdenv
, fetchurl

# pass a path to a config.yaml to be installed
, configFile ? null
}:

let
  pname = "strichliste";
  version = "1.7.1";
in

stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/strichliste/strichliste/releases/download/v${version}/strichliste.tar.gz";
    hash = "sha256-55QGwDp6KnWUX9yqWj24qo88/XY3QV0crvs0N9cKXMI=";
  };

  sourceRoot = ".";

  dontBuild = true;

  installPhase = ''
    mkdir $out
    cp -R * $out/
    '';

  postInstall = lib.optionalString (configFile != null) ''
    cp ${configFile} $out/config/strichliste.yaml
  '';

  meta = with lib; {
    description = "Self-Service Checklist: Manage your kiosk in a breeze";
    license = licenses.mit;
    homepage = "https://www.strichliste.org";
    changelog = "https://github.com/strichliste/strichliste/releases/tag/v${version}";
    maintainers = with maintainers; [ hexa ];
    platforms = platforms.all;
  };
}
