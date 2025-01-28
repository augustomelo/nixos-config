for func in $ZDOTDIR/functions/*(N:t); autoload $func

# The history configuration needs to be here, if the env varibles are on
# .zshenv they are rolled back to the default values
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=50000
export SAVEHIST=50000

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
