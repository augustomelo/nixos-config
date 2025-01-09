{
  description = "NixOS system and dotfiles configuration";

  inputs = {
    nixpkgs.url =  "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "aarch64-linux";
    in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/nixos.nix 
          ./users/augusto/user.nix
        ];
      };
    };
  };
}
