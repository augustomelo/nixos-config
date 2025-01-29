{ 
  config,
  lib,
  pkgs, 
  ...
}: 
let
  langs = [
    "br"
    "en"
  ];
  defaultCurlFlags = [
    "--fail"
    "--silent"
    "--show-error"
    "--location"
    "--output"
  ];
in
{
  home.activation.valeActivation = lib.hm.dag.entryAfter ["writeBoundary"] ''
    (
      dic_path=${config.xdg.dataHome}/dictionaries
      if [[ ! -d $dic_path ]]; then
        $DRY_RUN_CMD echo "Creating dictionary folder at: $dic_path"
        $DRY_RUN_CMD mkdir -p $dic_path
      fi

      vale_styles_spelling="${config.xdg.configHome}/vale/styles/spelling" 
      if [[ ! -d $vale_styles_spelling ]]; then
        $DRY_RUN_CMD mkdir -p $vale_styles_spelling
      fi

      yaml_content=$(echo "{}" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value 'spelling' 'extends')
      yaml_content=$(echo "$yaml_content" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value "\"%s\" is a typo!" 'message' )

      for lang in ${toString langs}; do
        $DRY_RUN_CMD echo "Dowlading dictionary: $lang"
        ${pkgs.curl}/bin/curl ${toString defaultCurlFlags} "$dic_path/$lang.dic" "https://raw.githubusercontent.com/wooorm/dictionaries/refs/heads/main/dictionaries/$lang/index.dic"
        ${pkgs.curl}/bin/curl ${toString defaultCurlFlags}  "$dic_path/$lang.aff" "https://raw.githubusercontent.com/wooorm/dictionaries/refs/heads/main/dictionaries/$lang/index.aff"
        yaml_content=$(echo "$yaml_content" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value "$lang" 'dictionaries.[]')
      done

      $DRY_RUN_CMD echo "$yaml_content" > "$vale_styles_spelling/Spelling.yaml"
    )
  '';
}
