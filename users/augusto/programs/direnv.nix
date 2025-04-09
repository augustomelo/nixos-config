{
  ...
}:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      # https://direnv.net/man/direnv.toml.1.html#whitelist
      whitelist = {
        prefix = [ "~/workspace" ];
      };
    };
  };
}
