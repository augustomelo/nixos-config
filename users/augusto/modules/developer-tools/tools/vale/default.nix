{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.developer-tools;
in
{
  imports = [
    ./activation/vale.nix
  ];

  config = lib.mkIf cfg.enable {
    home = {
      file.".config/vale" = {
        source = ./vale;
        recursive = true;
      };
    };

    packages = with pkgs; [
      vale
    ];
  };
}
