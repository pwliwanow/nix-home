{ config, lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    plugins = [
      {
        name = "powerlevel10k";
        file = "powerlevel10k.zsh-theme";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "v1.16.1";
          sha256 = "sha256-DLiKH12oqaaVChRqY0Q5oxVjziZdW/PfnRW1fCSCbjo=";
        };
      }
    ];
    oh-my-zsh = {
      enable = true;
      plugins = [
        "docker"
        "common-aliases"
        "git"
        "history"
        "per-directory-history"
        "sudo"
        "z"
      ];
    };
    initContent = ''
      if [[ -f "$HOME/.config/p10k/.p10k.zsh" ]]; then
        if [[ "$COMPOSER_NO_INTERACTION" == "1" ]]; then
          export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
          powerlevel10k_plugin_unload
        else
          source "$HOME/.config/p10k/.p10k.zsh"
        fi
      fi

      export EDITOR="vim"
      export GOPATH="$HOME/Developer/go"
      export PATH="$PATH:$HOME/Library/Python/3.8/bin"

      alias watchk8s="watch -n1 'timeout 10 kubectl get events -A --sort-by=.metadata.creationTimestamp | tac'"

      enable-sudo-touchid() {
        sudo sed -i -e '1s;^;auth       sufficient     pam_tid.so\n;' /etc/pam.d/sudo
      }

      curltime() {
        curl -w @- -o /dev/null -s "$@" <<'EOF'
          time_namelookup:  %{time_namelookup}\n
             time_connect:  %{time_connect}\n
          time_appconnect:  %{time_appconnect}\n
         time_pretransfer:  %{time_pretransfer}\n
            time_redirect:  %{time_redirect}\n
       time_starttransfer:  %{time_starttransfer}\n
                          ----------\n
               time_total:  %{time_total}\n
EOF
      }

      if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      export JAVA_HOME="${pkgs.jdk11}"

      source ${pkgs.kubesess}/shell-init/kubesess.sh
      source ${pkgs.kubesess}/shell-init/completion.sh
      unset HISTFILE

      alias kubectx="kcd"
    '';
  };
}
