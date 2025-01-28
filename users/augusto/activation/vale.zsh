#!/bin/zsh

if [[ ! -d $DICPATH ]]; then
  mkdir -p $DICPATH
fi

vale_styles_spelling="$XDG_CONFIG_HOME/vale/styles/spelling" 
if [[ ! -d $vale_styles_spelling ]]; then
  mkdir -p $vale_styles_spelling
fi

langs=("br" "en")
yaml_content=$(echo "{}" | dasel put --read yaml --type string --value 'spelling' 'extends')
yaml_content=$(echo "$yaml_content" | dasel put --read yaml --type string --value "\"%s\" is a typo!" 'message' )

for lang in "${langs[@]}"
do
  curl -o "$DICPATH/$lang.dic" "https://raw.githubusercontent.com/wooorm/dictionaries/refs/heads/main/dictionaries/$lang/index.dic"
  curl -o "$DICPATH/$lang.aff" "https://raw.githubusercontent.com/wooorm/dictionaries/refs/heads/main/dictionaries/$lang/index.aff"
  yaml_content=$(echo "$yaml_content" | dasel put --read yaml --type string --value "$lang" 'dictionaries.[]')
done

echo "$yaml_content" > "$vale_styles_spelling/Spelling.yaml"
