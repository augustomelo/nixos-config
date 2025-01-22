{
  description = "NixOS system and home-manager configuration";

  inputs = {
    nixpkgs.url =  "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... } :
    let
      host = "vm-aarch64-fusion";
      system = "aarch64-linux";
      username = "augusto";
    in {
    nixosConfigurations = {
      ${host} = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/${host}.nix
          ./users/${username}/user.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./users/${username}/home.nix;
            home-manager.extraSpecialArgs = { inherit username; };
          }
        ];
      };
    };
  };
}
