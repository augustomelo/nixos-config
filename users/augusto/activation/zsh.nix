{ pkgs, lib, config, ... }: 
{
  home.activation.zshActivation = lib.hm.dag.entryAfter ["writeBoundary"] ''
    (
      hist_folder=${config.xdg.stateHome}/zsh
      if [[ ! -d $hist_folder ]]; then
        $DRY_RUN_CMD mkdir -p $hist_folder
      fi

      completion_folder=${config.xdg.dataHome}/zsh/completion
      if [[ ! -d $completion_folder ]]; then
        $DRY_RUN_CMD mkdir -p $completion_folder
      fi

      $DRY_RUN_CMD ${pkgs.bat}/bin/bat --completion zsh > "$completion_folder/_bat"
      $DRY_RUN_CMD ${pkgs.colima }/bin/colima completion zsh > "$completion_folder/_colima"
      $DRY_RUN_CMD ${pkgs.dasel}/bin/dasel completion zsh >"$completion_folder/_dasel"
      $DRY_RUN_CMD ${pkgs.docker}/bin/docker completion zsh > "$completion_folder/_docker"
      # ghostty completion comes bundle up with the application
      $DRY_RUN_CMD ${pkgs.kubectl}/bin/kubectl completion zsh > "$completion_folder/_kubectl"
      $DRY_RUN_CMD ${pkgs.ripgrep}/bin/rg --generate complete-zsh > "$completion_folder/_rg"

      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_folder/_delta" https://raw.githubusercontent.com/dandavison/delta/refs/heads/main/etc/completion/completion.zsh
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_folder/_eza" https://raw.githubusercontent.com/eza-community/eza/refs/heads/main/completions/zsh/_eza
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_folder/_fd" https://raw.githubusercontent.com/sharkdp/fd/refs/heads/master/contrib/completion/_fd
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_folder/_fzf" https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/shell/completion.zsh
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_folder/_git" https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-completion.zsh
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_folder/_home-manager" https://raw.githubusercontent.com/nix-community/home-manager/refs/heads/master/home-manager/completion.zsh
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_folder/_hurl" https://raw.githubusercontent.com/Orange-OpenSource/hurl/refs/heads/master/completions/_hurl
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_folder/_hurlfmt" https://raw.githubusercontent.com/Orange-OpenSource/hurl/refs/heads/master/completions/_hurlfmt
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl --silent --show-error --output "$completion_folder/_zoxide" https://raw.githubusercontent.com/ajeetdsouza/zoxide/refs/heads/main/contrib/completions/_zoxide

      script_folder=${config.xdg.dataHome}/zsh/script
      if [[ ! -d $script_folder ]]; then
        $DRY_RUN_CMD mkdir -p $script_folder
      fi
      $DRY_RUN_CMD ${pkgs.curl}/bin/curl -o "$script_folder/git-completion.bash" https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-completion.bash
    )
  '';
}
