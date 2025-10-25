{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.developer-tools;
  dictSource = pkgs.fetchFromGitHub {
    owner = "wooorm";
    repo = "dictionaries";
    rev = "8cfea406b505e4d7df52d5a19bce525df98c54ab";
    hash = "sha256-trItzxKmZcTSplDd27PhJRbd4rvefghxiY4d67QnsEE=";
  };

  langs = [
    "br"
    "en"
  ];
in
{
  config = lib.mkIf cfg.enable {
    # https://github.com/errata-ai/vale/discussions/375
    home.activation.valeActivation = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      (
        vale_styles_path="${config.xdg.configHome}/vale/styles" 

        vale_config_dictionaries="$vale_styles_path/config/dictionaries"
        if [[ -d $vale_config_dictionaries ]]; then
          $DRY_RUN_CMD echo "Removing previous dictionaries at: $vale_config_dictionaries"
          $DRY_RUN_CMD rm -rf $vale_config_dictionaries
        fi

        $DRY_RUN_CMD echo "Creating dictionary folder at: $vale_config_dictionaries"
        $DRY_RUN_CMD mkdir -p $vale_config_dictionaries

        vale_styles_spelling="$vale_styles_path/spelling" 
        if [[ ! -d $vale_styles_spelling ]]; then
          $DRY_RUN_CMD echo "Creating dictionary folder at: $vale_styles_spelling"
          $DRY_RUN_CMD mkdir -p $vale_styles_spelling
        fi

        yaml_content=$(echo "{}" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value 'spelling' 'extends')
        yaml_content=$(echo "$yaml_content" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value "Did you really mean: \"%s\" ?" 'message' )
        yaml_content=$(echo "$yaml_content" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value error 'level' )

        for lang in ${toString langs}; do
          $DRY_RUN_CMD echo "Set up dictionary: $lang"
          ln -sf ${dictSource}/dictionaries/$lang/index.dic "$vale_config_dictionaries/$lang.dic"
          ln -sf ${dictSource}/dictionaries/$lang/index.aff "$vale_config_dictionaries/$lang.aff"
          yaml_content=$(echo "$yaml_content" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value "$lang" 'dictionaries.[]')
        done

        $DRY_RUN_CMD echo "$yaml_content" > "$vale_styles_spelling/Spelling.yml"
      )
    '';
  };
}
