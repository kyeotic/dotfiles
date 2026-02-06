{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkHome = { system, username, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
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
    in
    {
      homeConfigurations = {
        "kyeotic@macos" = mkHome {
          system = "aarch64-darwin";
          username = "kyeotic";
          homeDirectory = "/Users/kyeotic";
        };
        "kyeotic@linux" = mkHome {
          system = "x86_64-linux";
          username = "kyeotic";
          homeDirectory = "/home/kyeotic";
        };
        "tkye@macos" = mkHome {
          system = "aarch64-darwin";
          username = "tkye";
          homeDirectory = "/Users/tkye";
        };
      };
    };
}
