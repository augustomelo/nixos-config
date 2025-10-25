{
  config,
  lib,
  ...
}:
let
  cfg = config.developer-tools;
in
{
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        whitelist = {
          prefix = [ "~/workspace" ];
        };
        strict_env = true;
      };
    };
  };
}
