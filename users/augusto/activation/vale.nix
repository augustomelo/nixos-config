{ pkgs, lib, ... }: 
let
  langs = [
    "br"
    "en"
  ];
in
{
  home.activation.valeActivation = lib.hm.dag.entryAfter ["writeBoundary"] ''
    (
      if [[ ! -d $DICPATH ]]; then
        $DRY_RUN_CMD mkdir -p $DICPATH
      fi

      vale_styles_spelling="$XDG_CONFIG_HOME/vale/styles/spelling" 
      if [[ ! -d $vale_styles_spelling ]]; then
        $DRY_RUN_CMD mkdir -p $vale_styles_spelling
      fi

      langs=("br" "en")
      yaml_content=$(echo "{}" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value 'spelling' 'extends')
      yaml_content=$(echo "$yaml_content" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value "\"%s\" is a typo!" 'message' )

      for lang in "${toString langs}"
      do
        ${pkgs.curl}/bin/curl -o "$DICPATH/$lang.dic" "https://raw.githubusercontent.com/wooorm/dictionaries/refs/heads/main/dictionaries/$lang/index.dic"
        ${pkgs.curl}/bin/curl -o "$DICPATH/$lang.aff" "https://raw.githubusercontent.com/wooorm/dictionaries/refs/heads/main/dictionaries/$lang/index.aff"
        yaml_content=$(echo "$yaml_content" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value "$lang" 'dictionaries.[]')
      done

      $DRY_RUN_CMD echo "$yaml_content" > "$vale_styles_spelling/Spelling.yaml"
    )
  '';
}
