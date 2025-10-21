{
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      bash-language-server
      emmet-language-server
      gopls
      helm-ls
      jdt-language-server
      jsonnet-language-server
      lua-language-server
      markdownlint-cli
      nil
      nixfmt-rfc-style
      shellcheck
      shfmt
      terraform-ls
      tree-sitter
      typescript-language-server
      vale-ls
      yaml-language-server

      (python313.withPackages (
        ps: with ps; [
          pylsp-mypy
          pylsp-rope
          python-lsp-ruff
          python-lsp-server
        ]
      ))
    ];
  };
}
