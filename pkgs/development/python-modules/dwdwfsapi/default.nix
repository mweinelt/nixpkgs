{ lib
, buildPythonPackage
, isPy27
, fetchFromGitHub
, ciso8601
, requests
}:

buildPythonPackage rec {
  pname = "dwdwfsapi";
  version = "1.0.3";
  disabled = isPy27;

  src = fetchFromGitHub {
    owner = "stephan192";
    repo = pname;
    rev = "v${version}";
    sha256 = "13yy6c9j9yyc37j2pz7dlr97z2a708prffkm7hdz17nwdlldrlap";
  };

  propagatedBuildInputs = [
    ciso8601
    requests
  ];

  # tests require internet access
  doCheck = false;

  pythonImportsCheck = [ "dwdwfsapi" ];

  meta = with lib; {
    description = "Python client to retrieve data provided by DWD via their geoserver WFS API";
    homepage = "https://github.com/stephan192/dwdwfsapi";
    license = licenses.mit;
    maintainers = with maintainers; [ hexa ];
  };
}
