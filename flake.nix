{
  description = "Nix configuration";
  inputs = {
    hotPot = {
      url = "github:shopstic/nix-hot-pot";
    };

    nixpkgs.follows = "hotPot/nixpkgs";

    darwin = {
      url = "github:lnl7/nix-darwin/0413754b3cdb879ba14f6e96915e5fdf06c6aab6";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flakeUtils.follows = "hotPot/flakeUtils";
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
                  kubesess
                  k9s
                  dive
                  docker-credential-helpers
                  deno
                  ;
                # scala = prev.scala.override {
                #   jre = prev.jdk8;
                # };
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
          nix.settings = {
            cores = buildCores;
            max-jobs = maxJobs;
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
        mbp = darwin.lib.darwinSystem
          {
            system = "aarch64-darwin";
            modules = nixDarwinCommonModules { hostName = "pawel-mbp"; user = "pawel"; buildCores = 8; } ++ [{
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
