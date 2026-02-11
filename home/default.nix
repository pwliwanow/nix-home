{ config, lib, pkgs, ... }:
let
  sponge = pkgs.runCommand "sponge-symlink" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.moreutils}/bin/sponge $out/bin/sponge
  '';

  util-linux' = pkgs.runCommand "util-linux-symlinks" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.util-linux.bin}/bin/flock $out/bin/flock
    ln -s ${pkgs.util-linux.bin}/bin/setpgid $out/bin/setpgid
    ln -s ${pkgs.util-linux.bin}/bin/setsid $out/bin/setsid
  '';

  coreutils' = let
    # GNU-only: no macOS equivalent exists
    gnu-only = [
      "b2sum" "base32" "basenc" "chcon" "chroot" "dir" "dircolors"
      "factor" "hostid" "md5sum" "mknod" "nproc" "numfmt" "pinky"
      "ptx" "runcon" "sha1sum" "sha224sum" "sha256sum" "sha384sum"
      "sha512sum" "shred" "shuf" "stdbuf" "tac" "timeout" "vdir"
    ];
    # GNU version is better or equivalent to macOS built-in
    gnu-preferred = [
      "base64" "cat" "cut" "echo" "env" "expand" "expr" "false"
      "fmt" "fold" "head" "install" "join" "kill" "link" "ln"
      "mkdir" "mkfifo" "mktemp" "nice" "nl" "nohup" "od" "paste"
      "pr" "printenv" "printf" "pwd" "readlink" "realpath" "rm"
      "rmdir" "seq" "sleep" "sort" "split" "sync" "tail" "tee"
      "test" "[" "touch" "tr" "true" "truncate" "tsort" "tty"
      "uname" "unexpand" "uniq" "unlink" "wc" "yes"
    ];
    include = gnu-only ++ gnu-preferred;
  in pkgs.runCommand "coreutils-macos" { } ''
    mkdir -p $out/bin
    for name in ${lib.concatStringsSep " " include}; do
      ln -s "${pkgs.coreutils}/bin/$name" "$out/bin/$name"
    done
  '';

  restic-b2 = pkgs.writeShellScriptBin "restic-b2" ''
    set -euo pipefail

    CONFIG_DIR="$HOME/.config/restic"
    RESTIC="${pkgs.restic}/bin/restic"
    source "$CONFIG_DIR/b2.env"
    S3_CONNECTIONS=50
    SOURCES_FILE="$CONFIG_DIR/sources.conf"
    EXCLUDE_FILE="$CONFIG_DIR/excludes.txt"

    load_sources() {
      declare -gA SOURCES
      declare -ga SOURCE_ORDER
      [[ -f "$SOURCES_FILE" ]] || { echo "error: $SOURCES_FILE not found (format: name=/path)"; exit 1; }
      while IFS='=' read -r name path; do
        [[ -z "$name" || "$name" == \#* ]] && continue
        SOURCES["$name"]="$path"
        SOURCE_ORDER+=("$name")
      done < "$SOURCES_FILE"
    }

    do_backup() {
      if [[ "''${1:-}" == "--name" && -n "''${2:-}" ]]; then
        local name="$2"
        [[ -n "''${SOURCES[$name]+x}" ]] || { echo "Unknown source: $name (available: ''${!SOURCES[*]})"; exit 1; }
        echo "==> Backing up $name: ''${SOURCES[$name]}"
        $RESTIC backup "''${SOURCES[$name]}" --tag "$name" \
          --exclude-file="$EXCLUDE_FILE" \
          --exclude-if-present CACHEDIR.TAG --exclude-if-present .nobackup \
          -o s3.connections="$S3_CONNECTIONS"
      else
        for name in "''${SOURCE_ORDER[@]}"; do do_backup --name "$name"; done
      fi
    }

    case "''${1:-backup}" in
      backup)
        load_sources
        shift || true
        do_backup "$@"
        ;;
      *)
        $RESTIC -o s3.connections="$S3_CONNECTIONS" "$@"
        ;;
    esac
  '';
in
{
  imports = [
    ./dotfiles
    ./programs
  ];

  fonts.fontconfig.enable = true;

  news.display = "silent";

  home = {
    stateVersion = "23.05";
    path = lib.mkForce (pkgs.buildEnv {
      name = "home-manager-path";
      paths = config.home.packages;
      pathsToLink = [ "/bin" "/sbin" "/etc" "/include" "/share" "/lib" "/libexec" "/conf" "/shell-init" ];
      inherit (config.home) extraOutputsToInstall;
      postBuild = config.home.extraProfileCommands;
      meta = {
        description = "Environment of packages installed through home-manager";
      };
    });
    packages = builtins.attrValues
      {
        inherit sponge util-linux' restic-b2 coreutils';
        inherit (pkgs)
          meslo-lgs-nf
          regclient
          manifest-tool
          # rnix-lsp
          nixpkgs-fmt
          # nix-linter
          k9s
          kubectl
          # kubectx
          kubesess
          stern
          rsync
          gnused
          awscli2
          iperf2
          iperf3
          # inetutils
          gh
          gnupg
          watch
          tree
          wget
          nodejs_24
          pnpm
          yarn
          skopeo
          dive
          terraform
          jq
          amazon-ecr-credential-helper
          openssl
          pv
          deno
          nix-prefetch
          docker-credential-helpers
          rclone
          ffmpeg
          claude-code
          codex
          gemini-cli
          copilot
          ripgrep
          tmux
          python313
          uv
          temporal-cli
          cfn-nag
          ssm-session-manager-plugin
          opencode
          google-cloud-sdk
          # util-linux — only flock/setpgid/setsid cherry-picked above
          restic
          aiag
          changefeed
          nixx
          ;
      };
  };
}
