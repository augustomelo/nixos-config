{
  description = "NixOS system and home-manager configuration";

  inputs = {
    catppuccin.url = "github:catppuccin/nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
            ./hosts/devbox.nix
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
                  ./users/augusto/home-manager.nix
                  catppuccin.homeModules.catppuccin
                ];

                developerTools.enable = true;
              };
            }
          ];
        };
        home-server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/home-server.nix
            nixos-hardware.nixosModules.gmktec-nucbox-g3-plus
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
                sops-nix.homeManagerModules.sops
              ];
              home-manager.users.jb = {
                imports = [
                  ./users/jb/home-manager.nix
                  ./users/jb/containers
                ];
                homeServer.containers.enable = true;
              };
            }
          ];
        };
      };
    };
}
