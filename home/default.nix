{ config, lib, pkgs, ... }:
let
  sponge = pkgs.runCommand "sponge-symlink" {} ''
    mkdir -p $out/bin
    ln -s ${pkgs.moreutils}/bin/sponge $out/bin/sponge
  '';
in
{
  imports = [
    ./dotfiles
    ./programs
  ];

  fonts.fontconfig.enable = false;

  news.display = "silent";

  home = {
    stateVersion = "21.11";
    packages = builtins.attrValues
      {
        visualvm = pkgs.visualvm.override {
          jdk = pkgs.jdk11;
        };
        inherit sponge;
        inherit (pkgs)
          awscli2
          bat
          coreutils
          deno
          gh
          gnupg
          gnused
          iperf2
          iperf3
          inetutils
          jdk11
          jq
          k9s
          kubectl
          kubectx
          manifest-tool
          nix-linter
          nixpkgs-fmt
          regctl
          ripgrep
          rnix-lsp
          rsync
          sbt
          stern
          terraform
          tree
          vim
          watch
          wget
          ;
      };
  };
}
