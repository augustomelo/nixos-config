#!/bin/zsh

hist_folder="$XDG_STATE_HOME/zsh"
if [[ ! -d $hist_folder ]]; then
  mkdir -p $hist_folder
fi

completion_folder="$XDG_DATA_HOME/zsh/completion"
if [[ ! -d $completion_folder ]]; then
  mkdir -p $completion_folder
fi

bat --completion zsh > "$completion_folder/_bat"
colima completion zsh > "$completion_folder/_colima"
dasel completion zsh >"$completion_folder/_dasel"
docker completion zsh > "$completion_folder/_docker"
# ghostty completion comes bundle up with the application
kubectl completion zsh > "$completion_folder/_kubectl"
rg --generate complete-zsh > "$completion_folder/_rg"
wezterm shell-completion --shell zsh > "$completion_folder/_wezterm" 

curl -o "$completion_folder/_delta" https://raw.githubusercontent.com/dandavison/delta/refs/heads/main/etc/completion/completion.zsh
curl -o "$completion_folder/_eza" https://raw.githubusercontent.com/eza-community/eza/refs/heads/main/completions/zsh/_eza
curl -o "$completion_folder/_fd" https://raw.githubusercontent.com/sharkdp/fd/refs/heads/master/contrib/completion/_fd
curl -o "$completion_folder/_fzf" https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/shell/completion.zsh
curl -o "$completion_folder/_git" https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-completion.zsh
curl -o "$completion_folder/_home-manager" https://raw.githubusercontent.com/nix-community/home-manager/refs/heads/master/home-manager/completion.zsh
curl -o "$completion_folder/_hurl" https://raw.githubusercontent.com/Orange-OpenSource/hurl/refs/heads/master/completions/_hurl
curl -o "$completion_folder/_hurlfmt" https://raw.githubusercontent.com/Orange-OpenSource/hurl/refs/heads/master/completions/_hurlfmt
curl -o "$completion_folder/_zoxide" https://raw.githubusercontent.com/ajeetdsouza/zoxide/refs/heads/main/contrib/completions/_zoxide

script_folder="$XDG_DATA_HOME/zsh/script"
if [[ ! -d $script_folder ]]; then
  mkdir -p $script_folder
fi
curl -o "$script_folder/git-completion.bash" https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion/git-completion.bash

autoload -U compinit && compinit
