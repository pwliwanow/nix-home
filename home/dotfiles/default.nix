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
      "k9s/plugins.yaml" = {
        text = ''
          plugins:
            debug:
              shortCut: Shift-D
              description: Add debug container
              dangerous: true
              scopes:
                - containers
              command: bash
              background: false
              confirm: true
              args:
                - -c
                - "kubectl --kubeconfig=$KUBECONFIG debug -it --context $CONTEXT -n=$NAMESPACE $POD --target=$NAME --image=busybox:stable --share-processes -- sh"
        '';
      };
      "k9s/config.yaml" = {
        text = ''
          k9s:
            liveViewAutoRefresh: false
            screenDumpDir: /Users/nktpro/.local/state/k9s/screen-dumps
            refreshRate: 1
            maxConnRetry: 5
            readOnly: false
            noExitOnCtrlC: false
            ui:
              enableMouse: false
              headless: false
              logoless: false
              crumbsless: false
              noIcons: false
            skipLatestRevCheck: true
            disablePodCounting: false
            shellPod:
              image: busybox:1.35.0
              namespace: default
              limits:
                cpu: 100m
                memory: 100Mi
            imageScans:
              enable: false
              exclusions:
                namespaces: []
                labels: {}
            logger:
              tail: 5000
              buffer: 5000
              sinceSeconds: -1
              textWrap: false
              showTime: false
            thresholds:
              cpu:
                critical: 90
                warn: 70
              memory:
                critical: 90
                warn: 70

        '';
      };
    };
  };
}
