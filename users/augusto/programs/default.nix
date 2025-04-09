{
  ...
}:
{
  imports = [
    ./bat.nix
    ./direnv.nix
    ./fzf.nix
    ./ghostty.nix
    ./neovim.nix
    ./tmux.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  programs = {
    k9s.enable = true;
    starship.enable = true;
  };
}
