{ config, lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    plugins = [
      {
        name = "powerlevel10k";
        file = "powerlevel10k.zsh-theme";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "d281e595b3ddf2f5ccefb0cd7bfa475222566186";
          sha256 = "BoGgeDg1CrNnbU2SFqisJPVgWecAFZ2ri/p7q5Ss5aA=";
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
    initExtra = ''
      if [[ -f "$HOME/.config/p10k/.p10k.zsh" ]]; then
        source "$HOME/.config/p10k/.p10k.zsh"
      fi
      
      alias watchk8s="watch -n1 'timeout 10 kubectl get events -A --sort-by=.metadata.creationTimestamp | tac'"

      if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
      export JAVA_HOME="${pkgs.jdk11}"
    '';
  };
}
