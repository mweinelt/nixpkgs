{ config
, lib
, pkgs
, ...
}:

let
  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkPackageOptionMD
  ;

  cfg = config.services.authentik;

  python = cfg.package.python.interpreter;
in

{
  options.services.authentik = {
    enable = mkEnableOption (lib.mdDoc "Authentik");

    package = mkPackageOptionMD pkgs "authentik";
  };

  config = mkIf cfg.enable {
    systemd.services.authentik = {
      wantedBy = [
        "multi-user.target"
      ];
      after = [
        "postgresql.service"
      ];
      environment = {
        PYTHONPATH = cfg.package.pythonPath;
      };
      serviceConfig = {
        DynamicUser = true;
        User = "authentik";

        ExecStartPre = [
          "${python} -m lifecycle.wait_for_db"
          "${python} -m lifecycle.migrate"
        ];
        ExecStart = "${getExe cfg.package.python.pkgs.gunicorn} authentik.root.asgi";
      };
    };
  };
}
