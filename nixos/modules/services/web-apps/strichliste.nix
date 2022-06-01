{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.services.strichliste;
  fpm = config.services.phpfpm.pools.strichliste;
  format = pkgs.formats.yaml {};

  package = pkgs.strichliste.override {
    configFile = format.generate "strichliste.yaml" {
      parameters.strichliste = cfg.settings;
    };
  };
in
{
  options.services.strichliste = {
    enable = mkEnableOption "strichliste";

    settings = mkOption {
      type = types.submodule {
        freeformType = format.type;
        options = {
        };
      };
      description = ''
        Your <filename>strichliste.yaml</filename> as a Nix attribute set,
        ignoring the outer structure <literal>parameters.strichliste</literal>.

        Check the <link xlink:href="https://github.com/strichliste/strichliste-backend/blob/master/docs/Config.md"/>documentation</link> for possible values.
      '';
    };
  };

  config = lib.mkIf (cfg.enable) {

    services.nginx = {
      enable = true;
      virtualHosts."strichliste" = {
        root = package + "/public/";
        default = true;

        locations = {
          "/" = {
            tryFiles = "$uri /index.php$is_args$args";
          };
          "~ ^/index\.php(/|$)" = {
            fastcgiParams = {
              SCRIPT_FILENAME = "$document_root$fastcgi_script_name";
              PATH_INFO = "$fastcgi_path_info";

              modHeadersAvailable = "true";
              front_controller_active = "true";
            };
            extraConfig = ''
              fastcgi_split_path_info ^(.+\.php)(/.*)$;
              include ${config.services.nginx.package}/conf/fastcgi.conf;

              fastcgi_pass unix:${fpm.socket};
              fastcgi_intercept_errors on;
              fastcgi_request_buffering off;

              internal;
            '';
          };
          "~ \.php$" = {
            return = "404";
          };
        };
      };
    };

    users.users.strichliste = {
      group = "strichliste";
      isSystemUser = true;
      home = "/var/lib/strichliste";
    };

    users.groups.strichliste = {};

    services.phpfpm.pools.strichliste = {
      user = "strichliste";
      group = "strichliste";
      settings = {
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
        "pm" = "dynamic";
        "pm.max_children" = "32";
        "pm.start_servers" = "2";
        "pm.min_spare_servers" = "2";
        "pm.max_spare_servers" = "4";
        "pm.max_requests" = "500";
      };
    };
  };
}
