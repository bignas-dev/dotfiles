# .bashrc
[[ $- != *i* ]] && return

PS1='\e[92m\]\w $ \[\e[0m\]'

alias vi=nvim

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../..'
alias ......='cd ../../..'

alias ls='ls --color=always'
alias l=ls
alias ll='ls -lah'

alias grep='grep --color=always'

set -o vi
