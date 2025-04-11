# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k" # set by `omz`
DEFAULT_USER=$USER
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
source /etc/zsh_command_not_found

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
set -o vi

alias cvertical="xrandr --output DVI-D-0 --rotate left && exit"
alias lvertical="xrandr --output HDMI-0 --rotate left && exit"
alias screenreset="autorandr docked && exit"
alias rcopy="rsync -avvzh --delete --update --progress --partial"
alias leetcode="nvim leetcode.nvim"
alias prod="productivity.sh && exit"
alias window="window.sh && exit"
alias wa="whatsapp.sh && exit"
alias airplay="uxPlay.sh && exit"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Created by `pipx` on 2024-12-16 09:50:43
export PATH="$PATH:/home/c043/.local/bin"
export PATH="$PATH:/media/c043/Storage/EPICODE/c043-scripts"
export PATH="$PATH:/home/c043/.platformio/penv/bin"
export PATH="$PATH:/snap/bin"
