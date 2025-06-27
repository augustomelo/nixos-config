{
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      gopls
      helm-ls
      jdt-language-server
      lua-language-server
      markdownlint-cli
      nil
      nixfmt-rfc-style
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
