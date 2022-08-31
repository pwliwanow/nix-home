{
  description = "Nix configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flakeUtils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hotPot = {
      url = "github:shopstic/nix-hot-pot";
    };
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, flakeUtils, hotPot, ... }:
    let
      nixpkgsConfig = with inputs; {
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
        overlays = [
          (
            final: prev:
              let
                system = prev.stdenv.system;
              in
              {
                inherit (hotPot.packages.${system})
                  manifest-tool
                  regclient
                  awscli2
                  ;
                scala = prev.scala.override {
                  jre = prev.jdk8;
                };
              }
          )
        ];
      };

      homeManagerCommonConfig = with self.homeManagerModules; {
        imports = [
          ./home
        ];
      };

      nixDarwinCommonModules = { hostName, user, buildCores ? 8, maxJobs ? buildCores }: [
        # Main `nix-darwin` config
        ./darwin
        # `homeManager` module
        home-manager.darwinModules.home-manager
        # misc configs
        {
          nix = {
            buildCores = buildCores;
            maxJobs = maxJobs;
          };
          nixpkgs = nixpkgsConfig;
          # `home-manager` config
          users.users.${user}.home = "/Users/${user}";
          home-manager.useGlobalPkgs = true;
          home-manager.users.${user} = homeManagerCommonConfig;
          networking = {
            knownNetworkServices = [ "Wi-Fi" "Bluetooth PAN" "Thunderbolt Bridge" ];
            hostName = hostName;
            computerName = hostName;
            localHostName = hostName;
          };
        }
      ];
    in
    {
      darwinConfigurations = {
        studio-1 = darwin.lib.darwinSystem
          {
            system = "aarch64-darwin";
            modules = nixDarwinCommonModules { hostName = "studio-1"; user = "studio"; buildCores = 18; } ++ [{
              homebrew = {
                brewPrefix = "/opt/homebrew/bin";
              };
            }];
            specialArgs = {
              inherit inputs nixpkgs;
            };
          };
        studio-3 = darwin.lib.darwinSystem
          {
            system = "aarch64-darwin";
            modules = nixDarwinCommonModules { hostName = "studio-3"; user = "studio"; } ++ [{
              homebrew = {
                brewPrefix = "/opt/homebrew/bin";
              };
            }];
            specialArgs = {
              inherit inputs nixpkgs;
            };
          };
        mbp = darwin.lib.darwinSystem
          {
            system = "aarch64-darwin";
            modules = nixDarwinCommonModules { hostName = "jacky-mbp"; user = "nktpro"; } ++ [{
              homebrew = {
                brewPrefix = "/opt/homebrew/bin";
              };
            }];
            specialArgs = {
              inherit inputs nixpkgs;
            };
          };
        m1-mini = darwin.lib.darwinSystem
          {
            system = "aarch64-darwin";
            modules = nixDarwinCommonModules { hostName = "m1-mini"; user = "nktpro"; } ++ [{
              homebrew = {
                brewPrefix = "/opt/homebrew/bin";
              };
            }];
            specialArgs = {
              inherit inputs nixpkgs;
            };
          };
      };
    } //
    inputs.flakeUtils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = import ./shell.nix { inherit pkgs; };
      });
}
