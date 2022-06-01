import ./make-test-python.nix ({ pkgs, lib, ... }:

{
  name = "strichliste";
  meta.maintainers = with lib.maintainers; [ hexa ];

  nodes.server = { pkgs, ... }: {
    networking.extraHosts = ''
      127.0.0.1 strichliste
    '';

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "strichliste" ];
      ensureUsers = [{
        name = "strichliste";
        ensurePermissions = {
          "DATABASE strichliste" = "ALL PRIVILEGES";
        };
      }];
    };

    services.strichliste = {
      enable = true;
      settings = {};
    };
  };

  testScript = ''
    start_all()

    server.wait_for_unit("phpfpm-strichliste.service")
    server.wait_for_unit("nginx.service")

    server.wait_until_succeeds("curl --fail http://strichliste/index.php")
  '';
})
