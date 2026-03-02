{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }:
    let
      mkHome = { system, username, homeDirectory, isWork ? false }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit isWork; };
          modules = [
            ./home.nix
            {
              home = {
                inherit username homeDirectory;
                stateVersion = "24.05";
              };
            }
          ];
        };

      mkDarwin = { username, isWork ? false }:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username isWork; };
          modules = [
            ./darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit isWork; };
              home-manager.users.${username} = {
                imports = [ ./home.nix ];
                home = {
                  inherit username;
                  homeDirectory = "/Users/${username}";
                  stateVersion = "24.05";
                };
              };
              users.users.${username}.home = "/Users/${username}";
            }
          ];
        };
    in
    {
      homeConfigurations = {
        "kyeotic@linux" = mkHome {
          system = "x86_64-linux";
          username = "kyeotic";
          homeDirectory = "/home/kyeotic";
        };
      };

      darwinConfigurations = {
        "kyeotic" = mkDarwin {
          username = "kyeotic";
        };
        "tkye" = mkDarwin {
          username = "tkye";
          isWork = true;
        };
      };
    };
}
