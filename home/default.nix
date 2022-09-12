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
          regclient
          manifest-tool
          rnix-lsp
          nixpkgs-fmt
          nix-linter
          k9s
          kubectl
          kubectx
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
          nodejs-16_x
          yarn
          skopeo
          dive
          terraform
          jq
          amazon-ecr-credential-helper
          ;
      };
  };
}
