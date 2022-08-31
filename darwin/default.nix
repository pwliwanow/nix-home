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
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    readOnlyStore = true;
    nixPath = [
      "nixpkgs=/etc/${config.environment.etc.nixpkgs.target}"
      "home-manager=/etc/${config.environment.etc.home-manager.target}"
      "darwin=/etc/${config.environment.etc.darwin.target}"
    ];
    binaryCaches = lib.mkForce [
      "https://cache.nixos.org?priority=40"
      "https://nix.shopstic.com?priority=60"
    ];
    binaryCachePublicKeys = lib.mkForce [
      "nix-cache:jxOpK2dQOv/7JIb5/30+W4oidtUgmFMXLc/3mC09mKM="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
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
  programs.nix-index.package = pkgs.nix-index-unwrapped.overrideAttrs
    (attrs: rec {
      version = "0.1.3";
      name = "nix-index-${version}";

      src = pkgs.fetchFromGitHub {
        owner = "bennofs";
        repo = "nix-index";
        rev = "69f458004a95a609108b4c72da95b6c83d239a42";
        sha256 = "sha256-kExZMd1uhnOFiSqgdPpxp1txo+8MkgnMaGPIiTCCIQk=";
      };

      cargoDeps = attrs.cargoDeps.overrideAttrs (lib.const {
        name = "${name}-vendor.tar.gz";
        inherit src;
        outputHash = "sha256-GMY+IVNsJNvmQyAls3JF7Z9Bc92sNgNeMzzAN2yRKM8=";
      });
    });

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 4;
}
