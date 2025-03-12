{ config, lib, pkgs, ... }:
let
  sponge = pkgs.runCommand "sponge-symlink" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.moreutils}/bin/sponge $out/bin/sponge
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
    packages = builtins.attrValues
      {
        visualvm = pkgs.visualvm.override {
          jdk = pkgs.jdk11;
        };
        inherit sponge;
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
          inetutils
          gh
          gnupg
          watch
          coreutils
          tree
          jdk11
          wget
          nodejs_20
          yarn
          skopeo
          dive
          terraform
          jq
          amazon-ecr-credential-helper
          openssl
          scala
          pv
          deno
          nix-prefetch
          docker-credential-helpers
          rclone
          ;
      };
  };
}
