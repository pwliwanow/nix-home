{ config, pkgs, ... }:
{
  imports = [
    ./zsh.nix
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    fzf = {
      enable = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      ignores = [
        ".DS_Store"
        ".AppleDouble"
        ".LSOverride"

        # Icon must end with two \r
        "Icon"


        # Thumbnails
        "._*"

        # Files that might appear in the root of a volume
        ".DocumentRevisions-V100"
        ".fseventsd"
        ".Spotlight-V100"
        ".TemporaryItems"
        ".Trashes"
        ".VolumeIcon.icns"

        # Directories potentially created on remote AFP share
        ".AppleDB"
        ".AppleDesktop"
        "Network Trash Folder"
        "Temporary Items"
        ".apdisk"
      ];
      settings = {
        user = {
          name = "Jacky Nguyen";
          email = "nktpro@gmail.com";
        };
        alias = {
          co = "checkout";
          d = "diff";
          s = "status";
          pr = "pull --rebase";
          st = "status";
          l = "log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
        };
        core = {
          whitespace = "trailing-space,space-before-tab";
        };
        # commit.gpgsign = "true";
        # gpg.program = "gpg2";
        ui.color = "always";
        github.user = "nktpro";
        protocol.keybase.allow = "always";
        credential.helper = "osxkeychain";
        pull.rebase = "true";
      };
    };
    htop = {
      enable = true;
    };
  };

}
