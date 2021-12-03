{ config, lib, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    history = {
      path = ''$(if [[ -f "$PWD/.envrc" ]]; then echo "$PWD/.zsh_history"; else echo "$HOME/.zsh_history"; fi)'';
    };
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
      enable = false;
      plugins = [
        "git"
        "common-aliases"
      ];
    };
    initExtra = ''
      if [[ -f "$HOME/.config/p10k/.p10k.zsh" ]]; then
        source "$HOME/.config/p10k/.p10k.zsh"
      fi
      
      alias watchk8s="watch -n1 'timeout 4 kubectl get events -A --sort-by=.metadata.creationTimestamp | tac'"

      if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      export PATH="/Applications/Sublime Text.app/Contents/SharedSupport/bin:$PATH"
    '';
  };
}
