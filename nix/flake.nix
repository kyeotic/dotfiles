{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-gaming.url = "github:fufexan/nix-gaming";

    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    # use "nixos", or your hostname as the name of the configuration
    # it's a better practice than "default" shown in the video
    nixosConfigurations = {
      kye-1 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          {
            # pin system nixpkgs to the same version as the flake input
            # (don't see a way to declaratively set channels but this seems to work fine?)
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
          }
          ./hosts/kye-1/hardware-configuration.nix
          ./modules/default.nix
          # inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
