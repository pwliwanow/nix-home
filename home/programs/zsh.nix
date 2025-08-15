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
        # "git"
        # "common-aliases"
        "per-directory-history"
      ];
    };
    initContent = ''
      if [[ -f "$HOME/.config/p10k/.p10k.zsh" ]]; then
        source "$HOME/.config/p10k/.p10k.zsh"
      fi
      
      alias watchk8s="watch -n1 'timeout 10 kubectl get events -A --sort-by=.metadata.creationTimestamp | tac'"

      if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
      export JAVA_HOME="${pkgs.jdk11}"

      source ${pkgs.kubesess}/shell-init/kubesess.sh
      source ${pkgs.kubesess}/shell-init/completion.sh
      unset HISTFILE

      alias kubectx="kcd"
    '';
  };
}
