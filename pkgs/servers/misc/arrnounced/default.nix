{ lib
, fetchFromGitHub
, python3
}:

python3.pkgs.buildPythonApplication rec {
  pname = "arrnounced";
  version = "0.9.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "weannounce";
    repo = "arrnounced";
    rev = version;
    hash = "sha256-heKBGz4Bg09fcfNcqrwVDUYfAKLrggRZMT9BVY1Gb+8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'defusedxml = "0.6.0"' 'defusedxml = "*"' \
      --replace 'Flask = "1.1.1"' 'Flask = "*"' \
      --replace 'Flask-Login = "0.4.1"' 'Flask-Login = "*"' \
      --replace 'Flask-SocketIO = "^4.3.2"' 'Flask-SocketIO = "*"' \
      --replace 'pony = "0.7.14"' 'pony = "*"' \
      --replace 'tomlkit = "0.7.0"' 'tomlkit = "*"'
  '';

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aiohttp
    defusedxml
    flask
    flask_login
    flask-socketio
    pony
    tomlkit
    pydle
  ] ++ lib.optionals (python3.pythonOlder "3.8") [
    importlib-metadata
  ];

  checkInputs = with python3.pkgs; [
    coverage
  ];

  checkPhase = ''
    runHook preCheck
    ${python3.interpreter} ./run_tests.py
    runHook postCheck
  '';

  meta = with lib; {
    description = "Notify Sonarr/Radarr/Lidarr of tracker IRC announcements";
    homepage = "https://github.com/weannounce/arrnounced";
    license = licenses.unfree;
    maintainers = with maintainers; [ hexa ];
  };

}

