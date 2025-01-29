for func in $ZDOTDIR/functions/*(N:t); autoload $func

# https://zsh.sourceforge.io/Doc/Release/Options.html
setopt emacs \
  extendedhistory \
  histexpiredupsfirst \
  histignoreall_dups \
  histignoredups \
  histignorespace \
  histreduceblanks \
  histsavenodups \
  incappendhistory \
  sharehistory

eval "$(direnv hook zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

source "$ZDOTDIR/.aliases"
source "$ZDOTDIR/.fzf"
source "$ZDOTDIR/.zshcompletion"

bindkey -s "^Z" " fg^M"
