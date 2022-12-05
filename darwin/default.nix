{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ./brew.nix
  ];

  #####################
  # Nix configuration #
  #####################
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
      builders = @/etc/nix/machines
      builders-use-substitutes = true
      trusted-users = root ${lib.concatStringsSep " " (builtins.attrNames config.users.users)}
      narinfo-cache-negative-ttl = 0
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 60d";
    };
    readOnlyStore = true;
    nixPath = [
      "nixpkgs=/etc/${config.environment.etc.nixpkgs.target}"
      "home-manager=/etc/${config.environment.etc.home-manager.target}"
      "darwin=/etc/${config.environment.etc.darwin.target}"
    ];
    settings = {
      substituters = lib.mkForce [
        "https://cache.nixos.org?priority=40"
        "https://nix.shopstic.com?priority=60"
      ];
      trusted-public-keys = lib.mkForce [
        "nix-cache:jxOpK2dQOv/7JIb5/30+W4oidtUgmFMXLc/3mC09mKM="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

  ########################
  # System configuration #
  ########################

  # Fonts
  fonts.fontDir.enable = false;

  networking = {
    dns = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  services.nix-daemon.enable = true;

  ################
  # environment #
  ################

  environment = {
    etc = {
      home-manager.source = "${inputs.home-manager}";
      nixpkgs.source = "${inputs.nixpkgs}";
      darwin.source = "${inputs.darwin}";
    };
    extraInit = "";
    pathsToLink = [ "/Applications" ];
    shells = [ pkgs.zsh ];
    variables = {
      EDITOR = "subl -w";
      LC_ALL = "en_US.UTF-8";
      LIBRARY_PATH = "/usr/bin/gcc";
      SHELL = "${pkgs.zsh}/bin/zsh";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;
  };

  programs.bash.enable = true;

  programs.nix-index.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 4;
}
