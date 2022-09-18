# .bashrc
#
# This file is read by bash every time a shell starts.  Only put bash
# specific things (aliases, unexported variables) here.  Exported
# environment variables should be in .envrc, and path changes in .pathrc.

# Do not take the following lines out unless you're really sure of
# what you are doing.

function check_and_source {
    if [ -r $1 ]; then source $1; fi
}

check_and_source ~/.bash_functions
check_and_source ~/.aliases

export PATH=$HOME/bin:$PATH:/nix/profiles/sreerajkksd/default/bin

# If not running interactively, don't do anything from now onwards.
[ -z "$PS1" ] && return

check_and_source ~/bash_completion.d/_auto_completions.bash


who=`whoami`

if [ "${who}" == "${LOGNAME}" ]; then
    UA="$who@"
    COLOR="38;5;141m"
else
    UA="$who@"
    COLOR="38;5;155m"
fi

PS1='\[\e[$COLOR\][$?][\D{%T }${UA}${HOSTNAME} \w]> \[\e[m\]'
export PROMPT_DIRTRIM=2

# Set default visual editor
export VISUAL=vi
if [ -x "$(command -v vim)" ]; then
    export VISUAL=vim;
fi

#shell Options
shopt -s autocd cdspell expand_aliases no_empty_cmd_completion cmdhist nocaseglob dirspell checkwinsize

# History config
export HISTFILE=${HOME}/.eternal_history
export HISTTIMEFORMAT='%F %T '
export HISTCONTROL=ignoredups:erasedups:ignorespace
export HISTSIZE=100000
export HISTFILESIZE=100000
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a;"

# Python3 installation
export PYTHONNOCLEANSYSPATH="yes"


bind 'set bell-style none'

# export SSH_AUTH_SOCK=/tmp/karicher-ssh-agent.$HOSTNAME.sock


[ -f ~/.fzf.bash ] && source ~/.fzf.bash

## Control + F to search files
# https://github.com/junegunn/fzf/issues/546
bind -x '"\C-f": fzf-file-widget'
bind '"\C-t": transpose-chars'

fasd_cache="$HOME/.fasd-init-bash"
if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
  $HOME/bin/fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
fi

source "$fasd_cache"
unset fasd_cache
