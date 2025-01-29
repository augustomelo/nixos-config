{ lib, config, ... }: 
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

      script_path=${config.xdg.dataHome}/zsh/script
      if [[ ! -d $script_path ]]; then
        $DRY_RUN_CMD echo "Creating script folder at: $script_path"
        $DRY_RUN_CMD mkdir -p $script_path
      fi
    )
  '';
}
