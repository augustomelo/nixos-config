{
  description = "NixOS system and dotfiles configuration";

  inputs = {
    nixpkgs.url =  "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... } :
    let
      system = "aarch64-linux";
      username = "nix";
    in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/nixos.nix 
          ./users/augusto/user.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./users/augusto/home.nix;
            home-manager.extraSpecialArgs = { inherit username; };
          }
        ];
      };
    };
  };
}
