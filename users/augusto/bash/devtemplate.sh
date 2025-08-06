#!/usr/bin/env bash

# https://gist.github.com/mattmc3/804a8111c4feba7d95b6d7b984f12a53
local download_tmplt=''
local use_tmplt=''

while (( $# )); do
  case $1 in
    -d|--download)
      shift
      download_tmplt=$1
      ;;
    -d=*|--download=*)
      download_tmplt="${1#*=}"
      ;;
    -u|--use)
      shift
      use_tmplt=$1
      ;;
    -u=*|--use=*)
      use_tmplt="${1#*=}"
      ;;
    -h|--help)
      echo "Allowed option"
      echo " "
      echo "-d, --download={template} download a template from the-nix-way/dev-templates to extend it"
      echo "-u, --use={template}      use a template from the-nix-way/dev-templates"
      echo " "
      return
      ;;
  esac
  shift
done

if [[ -n $download_tmplt ]]; then
  echo "Running: nix flake init -t \"github:the-nix-way/dev-templates#$download_tmplt\""
  nix flake init -t "github:the-nix-way/dev-templates#$download_tmplt"
  echo "Running: direnv allow"
  direnv allow
  echo "Done!"
fi
if [[ -n $use_tmplt ]]; then
  echo "Creating .envrc with: use flake \"github:the-nix-way/dev-templates?dir=$use_tmplt\""
  echo "use flake \"github:the-nix-way/dev-templates?dir=$use_tmplt\"" >> .envrc
  echo "Running: direnv allow"
  direnv allow
  echo "Done!"
fi
