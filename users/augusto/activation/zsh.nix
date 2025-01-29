{ pkgs, lib, config, ... }: 
{
  home.activation.zshActivation = lib.hm.dag.entryAfter ["writeBoundary"] ''
    (
      hist_path=${config.xdg.stateHome}/zsh
      if [[ ! -d $hist_path ]]; then
        $DRY_RUN_CMD echo "Creating history folder at: $hist_path"
        $DRY_RUN_CMD mkdir -p $hist_path
      fi

      completion_path=${config.xdg.dataHome}/zsh/completion
      if [[ ! -d $completion_path ]]; then
        $DRY_RUN_CMD echo "Creating completion folder at: $completion_path"
        $DRY_RUN_CMD mkdir -p $completion_path
      fi

      $DRY_RUN_CMD ${pkgs.bat}/bin/bat --completion zsh > "$completion_path/_bat"
      $DRY_RUN_CMD ${pkgs.colima }/bin/colima completion zsh > "$completion_path/_colima"
      $DRY_RUN_CMD ${pkgs.dasel}/bin/dasel completion zsh >"$completion_path/_dasel"
      $DRY_RUN_CMD ${pkgs.docker}/bin/docker completion zsh > "$completion_path/_docker"
      # ghostty completion comes bundle up with the application
      $DRY_RUN_CMD ${pkgs.kubectl}/bin/kubectl completion zsh > "$completion_path/_kubectl"
      $DRY_RUN_CMD ${pkgs.ripgrep}/bin/rg --generate complete-zsh > "$completion_path/_rg"

      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_path/_delta" https://raw.githubusercontent.com/dandavison/delta/refs/heads/main/etc/completion/completion.zsh
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_path/_eza" https://raw.githubusercontent.com/eza-community/eza/refs/heads/main/completions/zsh/_eza
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_path/_fd" https://raw.githubusercontent.com/sharkdp/fd/refs/heads/master/contrib/completion/_fd
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_path/_fzf" https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/shell/completion.zsh
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_path/_git" https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-completion.zsh
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_path/_home-manager" https://raw.githubusercontent.com/nix-community/home-manager/refs/heads/master/home-manager/completion.zsh
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_path/_hurl" https://raw.githubusercontent.com/Orange-OpenSource/hurl/refs/heads/master/completions/_hurl
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_path/_hurlfmt" https://raw.githubusercontent.com/Orange-OpenSource/hurl/refs/heads/master/completions/_hurlfmt
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_path/_zoxide" https://raw.githubusercontent.com/ajeetdsouza/zoxide/refs/heads/main/contrib/completions/_zoxide

      script_path=${config.xdg.dataHome}/zsh/script
      if [[ ! -d $script_path ]]; then
        $DRY_RUN_CMD echo "Creating script folder at: $script_path"
        $DRY_RUN_CMD mkdir -p $script_path
      fi

      $DRY_RUN_CMD ${pkgs.curl}/bin/curl -o "$script_path/git-completion.bash" https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-completion.bash
    )
  '';
}
