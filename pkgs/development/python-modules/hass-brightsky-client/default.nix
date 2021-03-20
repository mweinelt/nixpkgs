{ lib
, buildPythonPackage
, fetchPypi
, poetry-core
, requests
}:

buildPythonPackage rec {
  pname = "hass-brightsky-client";
  version = "0.1.2";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "17qsw12nmxsnphcfhqqcxk60w10zka2dhxw2s5j7r15d1dzpf1gg";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    requests
  ];

  pythonImportsCheck = [
    "hass_brightsky_client"
  ];

  meta = with lib; {
    description = "Bright Sky API client for home-assiostant";
    homepage = "https://github.com/mweinelt/hass-brightsky-client";
    license = licenses.mit;
    maintainer = with maintainers; [ hexa ];
  };
}
