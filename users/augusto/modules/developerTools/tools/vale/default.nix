{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.developerTools;
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
