{
  description = "NixOS system and home-manager configuration";

  inputs = {
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      catppuccin,
      home-manager,
      nixos-hardware,
      nixpkgs,
      nixpkgs-stable,
      sops-nix,
      ...
    }:
    {
      nixosConfigurations = {
        devbox = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./hosts/vm-aarch64-fusion.nix
            ./users/augusto/user.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                pkgs-stable = import nixpkgs-stable {
                  system = "aarch64-linux";
                };
              };
              home-manager.users.augusto = {
                imports = [
                  ./users/augusto/home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
            }
          ];
        };
        home-server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/gmktec-nucbox-g3-plus.nix
            ./users/jb/user.nix
            nixos-hardware.nixosModules.gmktec-nucbox-g3-plus
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
                sops-nix.homeManagerModules.sops
              ];
              home-manager.users.jb = {
                imports = [
                  ./users/jb/home.nix
                ];
              };
            }
          ];
        };
      };
    };
}
