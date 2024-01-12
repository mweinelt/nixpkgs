{ config
, lib
, pkgs
, utils
, ...
}:

let
  inherit (lib)
    concatStringsSep
    mapAttrs'
    mapAttrsToList
    mdDoc
    mkIf
    mkMerge
    mkOption
    mkPackageOptionMD
    nullOr
    nameValuePair
    optional
    optionalAttrs
    types
  ;

  inherit (pkgs)
    writeShellScript
  ;

  inherit (utils)
    escapeSystemdExecArgs
  ;

  cfg = config.service.bupstash;

  putJob = with types; {
    enable = mkOption {
      type = bool;
      default = true;
      example = false;
      description = ''
        Whether to enable this backup job
      '';
    };

    user = mkOption {
      type = nullOr str;
      default = null;
      example = "postgres";
      description = mdDoc ''
        User to run this put job as. Defaults to `null`, which uses a dynamic user
        named `bupstash`, which has permissions to read all files system-wide through
        the use of the `CAP_DAC_READ_OVERRIDE` capability.
      '';
    };

    repository = mkOption {
      type = nullOr str;
      example = "ssh://offsite.example.com/machine.example.com";
      description = mdDoc ''
        The repository to backup the paths into. Available as `BUPSTASH_REPOSITORY`.
      '';
    };

    repositoryCommand = mkOption {
      type = nullOr str;
      example = "ssh -l backup -i /run/keys/bupstash/id_bupstash offsite.example.com";
      description = mdDoc ''
        The command to run to connect to an instance of `bupstash-serve`. Available as
        `BUPSTASH_REPOSITORY_COMMAND`.
      '';
    };

    key = mkOption {
      type = nullOr str;
      description = mdDoc ''
        Path to the encryption key that is allowed to put to the repository. Available
        as `BUPSTASH_KEY`.

        Relevant documentation:
        - [Secure offline keys](https://bupstash.io/doc/guides/Secure%20Offline%20Keys.html)
      '';
    };

    keyCommand = mkOption {
      type = nullOr str;
      example = "cat /run/keys/bupstash/put.key";
      description = mdDoc ''
        Command to retrieve the encryption key, that is allowed to put to the repository.
        Available as `BUPSTASH_KEY_COMMAND`.

        Relevant documentation:
        - [Secure offline keys](https://bupstash.io/doc/guides/Secure%20Offline%20Keys.html)
      '';
    };

    tags = mkOption {
      type = attrsOf str;
      default = { };
      example = literalExample ''
        {
          name = "example.zip"
        }
      '';
      description = ''
        Key/value pairs attached to the data stored through the put call.
      '';
    };

    paths = mkOption {
      type = nullOr (listOf path);
      default = null;
      example = [
        "/home/"
        "/var/backup"
        "/var/lib"
      ];
      description = ''
        List of files or directories to save.
      '';
    };

    exec = mkOtion {
      type = nullOr str;
      default = null;
      example = literalExample ''
        ''${config.services.postgresql.package}/bin/pg_dump
      '';
    };

    extraArgs = mkOption {
      type = listOf str;
      default = [];
      examples = literalExample ''
        [
          "--no-send-log"
        ]
      '';
      description = ''
        List of parameters and arguments to append to the `bupstash put` command.
      '';
    };

    preHook = mkOption {
      type = nullOr lines;
      default = null;
      example = literalExpression ''\
        # https://openzfs.github.io/openzfs-docs/man/8/zfs-snapshot.8.html
        ''${config.boot.zfs.package}/bin/zfs snapshot -r pool/state@backup
      '';
      description = ''
        Commands that are run before the put job is run. Executed with root permissions.

        Useful to create snapshots or modify the environment variables consumed by bupstash.
      '';
    };

    postHook = mkOption {
      type = nullOr lines;
      default = null;
      example = literalExpression ''
        # https://openzfs.github.io/openzfs-docs/man/8/zfs-snapshot.8.html
        ''${config.boot.zfs.package}/bin/zfs destroy -r pool/state@backup
      '';
      description = ''
        Commands that are run before the put job is run.

        Useful to remove snapshots or modify the environment variables consumed by bupstash.
      '';
    };
  };

  mkPutService = name: job: nameValuePair "bupstash-put-${name}" {
    description = "Bupstash Put Job";
    documentation = [
      "man:bupstash-put(1)"
      "https://bupstash.io/doc/man/bupstash-put.html"
    ];
    environment = {
      # TODO: Check whether null values create environment variables
      # https://bupstash.io/doc/man/bupstash-put.html#ENVIRONMENT
      BUPSTASH_REPOSITORY = job.repository;
      BUPSTASH_REPOSITORY_COMMAND = job.repositoryCommand;
      BUPSTASH_KEY = job.key;
      BUPSTASH_KEY_COMMAND = job.keyCommand;
      # Enables storing the send log for incremental backups
      HOME = "/var/lib/bupstash";
    };
    serviceConfig = {
      ExecStart = concatStringsSep " " (escapeSystemdExecArgs ([
        (lib.getExe cfg.package)
        "put"
      ]
      ++ job.extraArgs
      ++ optional (job.exec != null) "--exec"
      # https://github.com/andrewchambers/bupstash/issues/389
      ++ mapAttrsToList (k: v: "${k}=${v}\n") job.extraArgs
      ++ [
        "::"
        job.paths or job.exec
      ]));

      ExecStartPre = mkIf (job.preHook != null)
        ("+" + writeShellScript "bupstash-put-${job.name}-prehook" job.preHook);
      ExecStopPost = mkIf (job.postHook != null)
        ("+" + writeShellScript "bupstash-put-${job.name}-posthook" job.postHook);

      # TODO: Hardening
      UMask = "0077";
      StateDirectory = "bupstash";
      StateDirectoryMode = "0700";

    } // optionalAttrs (job.user == null) {
      DynamicUser = true;
      User = "bupstash";

      AmbientCapabilities = [
        "CAP_DAC_READ_OVERRIDE"
      ];
      Capabilities = [
        "CAP_DAC_READ_OVERRIDE"
      ];
    } // optionalAttrs (job.user != null) {
      User = job.user;

      AmbientCapabilities = [ "" ];
      Capabilities = [ "" ];
    };
  };
in {
  options.services.bupstash = with types; {
    package = mkPackageOptionMD pkgs "bupstash" { };

    putJobs = mkOption {
      description = mdDoc ''
        Bupstash put jobs configuration.

        Relevant documentation:
        - [bupstash-put](https://bupstash.io/doc/man/bupstash-put.html)
      '';
      default = { };
      type = attrsOf putJob;
    };
  };

  config = mkMerge [
    (mkIf (cfg.jobs != []) {
      assertions = mapAttrsToList (name: job: {
        assertion = job.paths == null || job.exec == null;
        message = "Bupstash job `${name}` cannot use both `exec` and `path`.";
      } // {
        assertion = job.key == null || job.keyCommand == null;
        message = "Bupstash job `${name}` cannot use both `key` and `keyCommand`";
      } // {
        assertion = job.repository == null || job.repositoryCommand == null;
        message = "Bupstash job `${name}` cannot use both `repository` and `repositoryCommand`";
      });

      systemd.services = mapAttrs' mkPutService cfg.jobs;
    })

    # TODO: repositories management
  ];
}
