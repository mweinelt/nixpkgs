{ lib
, buildPythonPackage
, fetchFromGitHub

# extra: GSSAPI
, kerberos

# tests
, mock
, pytestCheckHook
, six
}:

buildPythonPackage rec {
  pname = "pure-sasl";
  version = "0.6.2";
  format = "setuptools";

  # only publishes wheels
  src = fetchFromGitHub {
    owner = "thobbs";
    repo = pname;
    rev = version;
    hash = "sha256-AHoZ3QZLr0JLE8+a2zkB06v2wRknxhgm/tcEPXaJX/U=";
  };

  passthru.extras-require.GSSAPI = [
    kerberos
  ];

  checkInputs = [
    mock
    pytestCheckHook
    six
  ]
  ++ passthru.extras-require.GSSAPI;

  pythonImportsCheck = [
    "puresasl"
  ];

  meta = with lib; {
    description = "Pure Python client SASL implementation";
    homepage = "https://github.com/thobbs/pure-sasl/blob/master/setup.py";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
