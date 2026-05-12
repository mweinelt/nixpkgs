{
  lib,
  appdirs,
  buildPythonPackage,
  fetchFromGitHub,
  hatch-vcs,
  hatchling,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "platformdirs";
  version = "4.9.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tox-dev";
    repo = "platformdirs";
    tag = version;
    hash = "sha256-/aoJquWRn1UQZa96uZba15tDO+IGEHN9/duu9JYXmd4=";
  };

  build-system = [
    hatchling
    hatch-vcs
  ];

  nativeCheckInputs = [
    appdirs
    pytest-mock
    pytestCheckHook
  ];

  disabledTests = [
    # expects site prefix below /usr/local/share, but we're in the nix store
    "test_use_site_for_root_as_root"
    "test_use_site_for_root_bypasses_xdg_user_vars"
  ];

  pythonImportsCheck = [ "platformdirs" ];

  meta = {
    description = "Module for determining appropriate platform-specific directories";
    homepage = "https://platformdirs.readthedocs.io/";
    changelog = "https://github.com/tox-dev/platformdirs/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
