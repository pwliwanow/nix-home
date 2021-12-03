{
  description = "Nix configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/21.11";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flakeUtils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hotPot = {
      url = "github:shopstic/nix-hot-pot";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flakeUtils.follows = "flakeUtils";
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
                  ;
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
        hackintosh = darwin.lib.darwinSystem
          {
            system = "x86_64-darwin";
            modules = nixDarwinCommonModules { hostName = "jacky-oc"; user = "nktpro"; };
            specialArgs = {
              inherit inputs nixpkgs;
            };
          };
        x86-mbp = darwin.lib.darwinSystem
          {
            system = "x86_64-darwin";
            modules = nixDarwinCommonModules { hostName = "jacky-mbp-x86"; user = "nktpro"; maxJobs = 4; };
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
