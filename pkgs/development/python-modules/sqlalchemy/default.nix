{ stdenv
, lib
, fetchPypi
, buildPythonPackage
, isPy3k
, pythonOlder
, greenlet
, importlib-metadata
, mock
, pysqlite ? null
, pytestCheckHook
, pytest_xdist
}:

buildPythonPackage rec {
  pname = "SQLAlchemy";
  version = "1.4.18";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d25210f5f1a6b7b6b357d8fa199fc1d5be828c67cc1af517600c02e5b2727e4c";
  };

  propagatedBuildInputs = [
    greenlet
  ] ++ lib.optionals (pythonOlder "3.8") [
    importlib-metadata
  ];

  checkInputs = [
    pytestCheckHook
    mock
  ] ++ lib.optional (!isPy3k) pysqlite;

  postInstall = ''
    sed -e 's:--max-worker-restart=5::g' -i setup.cfg
  '';

  dontUseSetuptoolsCheck = true;

  # disable mem-usage tests on mac, has trouble serializing pickle files
  disabledTests = lib.optionals stdenv.isDarwin [
    "MemUsageWBackendTest"
    "MemUsageTest"
  ];

  meta = with lib; {
    homepage = "http://www.sqlalchemy.org/";
    description = "A Python SQL toolkit and Object Relational Mapper";
    license = licenses.mit;
  };
}
