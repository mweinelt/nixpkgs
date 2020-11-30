{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.url-bot-rs;
  format = pkgs.formats.toml {};

  configFiles = mapAttrsToList (name: val: format.generate "${name}.toml" {
    connection = {
      nickname = val.nickname;
      alt_nicks = val.altNicks;
      server = val.server;
      password = val.password;
      port = val.port;
      use_ssl = val.ssl;
      channels = val.channels;
      nick_password = val.nickPassword;
    };
    features = genAttrs val.features (name: true);
    parameters = { status_channels = val.statusChannels; };
    database = if val.sqliteDb then { type = "sqlite"; path = "/var/lib/url-bot-rs/${name}.db"; } else {};
    network = { name = "${name}"; enable = val.enable; };
    plugins = {
      youtube = { api_key = val.youtubeAPIKey; };
      imgur = { api_key = val.imgurAPIKey; };
    };
  }) cfg.networks;

  serverOpts = { name, ... }: {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable connection to this IRC network.
        '';
      };

      nickname = mkOption {
        type = types.str;
        default = "url-bot-rs";
        example = "urlify";
        description = ''
          Primary nickname of the bot on IRC.
        '';
      };

      altNicks = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["url-bot-rs_" "url-bot-rs__"];
        description = ''
          List of alternative nicks to use if the primary nick is taken.
        '';
      };

      nickPassword = mkOption {
        type = types.str;
        default = "";
        description = ''
          Password for the primary nick.
        '';
      };

      server = mkOption {
        type = types.str;
        example = "irc.example.com";
        description = ''
          Hostname of the IRC server to connect to.
        '';
      };

      password = mkOption {
        type = types.str;
        default = "";
        description = ''
          Password for the IRC server.
        '';
      };

      port = mkOption {
        type = types.port;
        default = 6667;
        example = 6697;
        description = ''
          Port of the IRC server to connect to.
        '';
      };

      ssl = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable SSL/TLS on the IRC connection.
        '';
      };

      channels = mkOption {
        type = types.listOf types.str;
        default = [];
        example = ["#nixos"];
        description = ''
          List of channels the bot joins on connect.
        '';
      };

      features = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "history" "reconnect" "report_metadata" ];
        description = ''
          List of bot features to enable.
        '';
      };

      statusChannels = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "#url-bot-rs-status" ];
        description = ''
          List of channels to post status information to.
        '';
      };

      sqliteDb = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable sqlite database and pre-post information.
          Note that you must also enable the <literal>history</literal>
          feature for this to work.
        '';
      };

      youtubeAPIKey = mkOption {
        type = types.str;
        default = "";
        description = ''
          YouTube API key to use for title retrieval. Adding the API key here
          will enable the YouTube plugin automatically.
        '';
      };

      imgurAPIKey = mkOption {
        type = types.str;
        default = "";
        description = ''
          Imgur API key to use for title retrieval. Adding the API key here
          will enable the Imgur plugin automatically.
        '';
      };

    };
  };

in
{
  options.services.url-bot-rs = {
    enable = mkEnableOption "Minimal IRC URL bot in Rust";

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "--verbose" ];
      description = ''
        List of additional command line parameters for url-bot-rs.
      '';
    };

    networks = mkOption {
        type = with types; attrsOf (submodule serverOpts);
        description = "Attribute set of servers to connect to, and their configuration options";
        example = ''
          "examplenet" = {
            nickname = "urlify";
            server = "irc.example.com";
            port = "6697";
            ssl = true;
            channels = [ "#nixos" ];
            features = [ "history" "reconnect" "report_metadata" ];
            sqliteDb = true;
          }
        '';
      };

  };

  config = mkIf cfg.enable {
    systemd.services.url-bot-rs = {
      description = "Minimal IRC URL bot in Rust";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.url-bot-rs}/bin/url-bot-rs -c " + concatStringsSep " -c " configFiles + concatStringsSep " " cfg.extraArgs;
        DynamicUser = true;
        Restart = "always";
        RestartSec = 10;

        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        DeviceAllow = [
          "/dev/stdin"
          "/dev/stdout"
          "/dev/stderr"
        ];
        DevicePolicy = "strict";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateNetwork = false;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        StateDirectory = "url-bot-rs";
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        UMask = "0177";

      };
    };
  };
}
