{
  description = "NixOS system and home-manager configuration";

  inputs = {
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
  };

  outputs =
    {
      catppuccin,
      home-manager,
      nixpkgs,
      nixpkgs-stable,
      ...
    }:
    let
      host = "vm-aarch64-fusion";
      system = "aarch64-linux";
      username = "augusto";
    in
    {
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
              home-manager.extraSpecialArgs = {
                pkgs-stable = import nixpkgs-stable {
                  inherit system;
                };
              };
              home-manager.users.${username} = {
                imports = [
                  ./users/${username}/home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
            }
          ];
        };
      };
    };
}
