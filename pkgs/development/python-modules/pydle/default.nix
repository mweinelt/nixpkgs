{ lib
, buildPythonPackage
, fetchFromGitHub

# extra: sasl
, pure-sasl

# tests
, mock
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "pydle";
  version = "0.9.4";
  format = "setuptools";

  # only publishes wheels
  src = fetchFromGitHub {
    owner = "Shizmob";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-waq+pY0fHLPkmAyuP2UFKAskMVj+fxbN93eCWhgSzb4=";
  };

  passthru.extras-require = {
    sasl = [
      pure-sasl
    ];
  };

  # https://github.com/Shizmob/pydle/issues/78
  doCheck = false;

  checkInputs = [
    mock
    pytestCheckHook
  ]
  ++ passthru.extras-require.sasl;

  pythonImportsCheck = [
    "pydle"
    "pydle.features"
    "pydle.features.rpl_whoishost"
    "pydle.features.rfc1459"
    "pydle.features.ircv3"
    "pydle.utils"
  ];

  meta = with lib; {
    description = "Pure Python client SASL implementation";
    homepage = "https://github.com/thobbs/pure-sasl/blob/master/setup.py";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
