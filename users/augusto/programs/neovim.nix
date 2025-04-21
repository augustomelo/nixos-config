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
      nil
      nixfmt-rfc-style
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
