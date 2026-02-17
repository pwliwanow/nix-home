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
          rev = "master";
          sha256 = "sha256-BRJyGn+gTGUWifpJ1ziBKVHACcWw+R5N/HdUi8HzSvY=";
        };
      }
    ];
    oh-my-zsh = {
      enable = true;
      extraConfig = ''
        if [[ "$COMPOSER_NO_INTERACTION" != "1" && "$CURSOR_AGENT" != "1" ]]; then
          plugins=(per-directory-history)
        fi
      '';
    };
    initContent = ''
      if [[ -f "$HOME/.config/p10k/.p10k.zsh" ]]; then
        if [[ "$COMPOSER_NO_INTERACTION" == "1" || "$CURSOR_AGENT" == "1" ]]; then
          export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
          powerlevel10k_plugin_unload
        else
          source "$HOME/.config/p10k/.p10k.zsh"
        fi
      fi

      alias watchk8s="watch -n1 'timeout 10 kubectl get events -A --sort-by=.metadata.creationTimestamp | tac'"

      if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
      export JAVA_HOME="${pkgs.jdk11}"

      unset HISTFILE

      eval "$(kubesess init zsh)"
      alias kubectx="kcd"
      alias claude-diet='DISABLE_AUTO_COMPACT=1 claude --dangerously-skip-permissions --disallowed-tools="WebFetch,WebSearch,NotebookEdit,AskUserQuestion,Skill,EnterPlanMode,ExitPlanMode"'
    '';
  };
}
