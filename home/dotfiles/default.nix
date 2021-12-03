{ config, pkgs, ... }:
{
  xdg = {
    enable = true;
    configFile = {
      p10k = {
        source = ./p10k;
        recursive = true;
      };
      "direnv/direnvrc" = {
        text = ''
          : ''${XDG_CACHE_HOME:=$HOME/.cache}
          declare -A direnv_layout_dirs
          direnv_layout_dir() {
              echo "''${direnv_layout_dirs[$PWD]:=$(
                  echo -n "$XDG_CACHE_HOME"/direnv/layouts/
                  echo -n "$PWD" | shasum | cut -d ' ' -f 1
              )}"
          }
        '';
      };
    };
  };
}
