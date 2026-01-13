{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault 
    mkEnableOption 
    mkIf
    mkOption
    mkPackageOption
    mkRenamedOptionModule
    types;

  php = pkgs.php81;
  cfg = config.services.strichliste;
in {
  options.services.strichliste = {
    enable = mkEnableOption "strichliste, a web based tally sheet.";

    # TODO Change "pkgs.local" to "pkgs"
    package-frontend = mkPackageOption pkgs.local "strichliste-frontend" { };
    package-backend = mkPackageOption pkgs.local "strichliste-backend" { };

    domain = mkOption {
      type = types.str;
      example = "strichliste.example.com";
      description = "Domain to serve on.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx.enable = true;
    services.nginx.virtualHosts.${cfg.domain} = {
      root = "${cfg.package-frontend}";
      locations = {

        "/" = {
          tryFiles = "$uri /index.php$is_args$args";
          priority = 400;
        };

        "~ ^/index\.php$" = {
          root = "${cfg.package-backend}/share/php/strichliste-backend/public";
          fastcgiParams = {
            SCRIPT_FILENAME = "$document_root$fastcgi_script_name";
            PATH_INFO = "$fastcgi_path_info";

            modHeadersAvailable = "true";
            front_controller_active = "true";
          };
          extraConfig = ''
            fastcgi_split_path_info ^(.+\.php)(/.*)$;

            fastcgi_pass unix:${config.services.phpfpm.pools.strichliste.socket};
            fastcgi_intercept_errors on;
            fastcgi_request_buffering off;

            internal;
          '';
          priority = 500;
        };

      };
    };

    systemd.services.init-strichliste = {
      wantedBy = [ "multi-user.target" ];
      before = [ "phpfpm-strichliste.service" ];
      serviceConfig = {
        User = "strichliste";
        type = "oneshot";
      };
      script = ''
        set -ex
        test -e '${cfg.databaseFile}' || {
          cd ${cfg.package-backend}
          ./bin/console doctrine:database:create
          ./bin/console doctrine:schema:create
        }
      '';
    };

    services.phpfpm = {
      pools.strichliste = {
        user = "strichliste";
        group = "users";
        settings = {
          "listen.owner" = "nginx";
          "listen.group" = "nginx";
          pm = "dynamic";
          "pm.max_children" = 8;
          "pm.start_servers" = 1;
          "pm.min_spare_servers" = 1;
          "pm.max_spare_servers" = 4;
          "pm.max_requests" = 256;
        };
        phpPackage = php;
      };
    };

    users.groups.strichliste = {};
    users.users.strichliste = {
      group = "strichliste";
      home = "/var/lib/strichliste";
      createHome = true;
      isSystemUser = true;
    };

  };
}
