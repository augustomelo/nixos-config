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
      python313Packages.python-lsp-server
      vale-ls
      yaml-language-server
    ];
  };
}
