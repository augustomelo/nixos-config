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
  config = lib.mkIf cfg.enable {
    home.file.".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };

    programs.neovim = {
      enable = true;
      extraPackages = with pkgs; [
        bash-language-server
        emmet-language-server
        gopls
        gotools
        helm-ls
        jdt-language-server
        jsonnet-language-server
        lua-language-server
        markdownlint-cli
        nil
        nixfmt
        pyrefly
        ruff
        shellcheck
        shfmt
        terraform-ls
        tree-sitter
        typescript-language-server
        vale-ls
        yaml-language-server
      ];
      withPython3 = false;
      withRuby = false;
    };
  };
}
