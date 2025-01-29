{ 
  config,
  lib,
  pkgs, 
  ...
}: 
let
  dictSoure = pkgs.fetchFromGitHub {
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
        $DRY_RUN_CMD echo "Set up dictionary: $lang"
        cp ${dictSoure}/dictionaries/$lang/index.dic "$dic_path/$lang.dic"
        cp ${dictSoure}/dictionaries/$lang/index.aff "$dic_path/$lang.aff"
        yaml_content=$(echo "$yaml_content" | ${pkgs.dasel}/bin/dasel put --read yaml --type string --value "$lang" 'dictionaries.[]')
      done

      $DRY_RUN_CMD echo "$yaml_content" > "$vale_styles_spelling/Spelling.yaml"
    )
  '';
}
