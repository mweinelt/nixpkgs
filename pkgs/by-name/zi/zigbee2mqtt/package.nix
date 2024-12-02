{ lib
, stdenv
, fetchFromGitHub
, nodejs
, npmHooks
, pnpm
, systemdMinimal
, nixosTests
, nix-update-script
, withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemdMinimal
}:

stdenv.mkDerivation rec {
  pname = "zigbee2mqtt";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "Koenkk";
    repo = "zigbee2mqtt";
    rev = "dev";
    hash = "sha256-PUJYu0OslhIth6h3Y6r3ocQrMpsFxqBoCRVuXWoCxGo=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    hash = "sha256-6CXTE4LOdRZOxRq6hpVzdWPOifj59jyhZNfW7bUdlyc=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmBuildHook
    npmHooks.npmInstallHook
    pnpm.configHook
  ];

  npmBuildScript = "build";
  npmBuildFlags = lib.optionals (!withSystemd) [ "--omit=optional" ];

  buildInputs = lib.optionals withSystemd [
    systemdMinimal
  ];

  #env.dontNpmPrune = true;
  preInstall = ''
    set -x
  '';

  postInstall = ''
    set x
  '';

  passthru.tests.zigbee2mqtt = nixosTests.zigbee2mqtt;
  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    changelog = "https://github.com/Koenkk/zigbee2mqtt/releases/tag/${version}";
    description = "Zigbee to MQTT bridge using zigbee-shepherd";
    homepage = "https://github.com/Koenkk/zigbee2mqtt";
    license = licenses.gpl3;
    longDescription = ''
      Allows you to use your Zigbee devices without the vendor's bridge or gateway.

      It bridges events and allows you to control your Zigbee devices via MQTT.
      In this way you can integrate your Zigbee devices with whatever smart home infrastructure you are using.
    '';
    maintainers = with maintainers; [ sweber hexa ];
    mainProgram = "zigbee2mqtt";
  };
}
