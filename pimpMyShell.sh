#!/bin/zsh

ZSH=$HOME/.oh-my-zsh

echo "You need zsh and git for this script to work, do you have them installed? [y/n]"
read answer

if[[ $answer == "y" || $answer == "Y" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    export ZSH_CUSTOM=~/.oh-my-zsh/custom
    git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo "ZSH='$HOME/.oh-my-zsh'" > ~/.zshrc
    echo "ZSH_THEME='powerlevel10k/powerlevel10k'" >> ~/.zshrc
    echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)" >> ~/.zshrc
    echo "source $ZSH/oh-my-zsh.sh" >> ~/.zshrc
    echo "set -o vi" >> ~/.zshrc
    echo "All done, source ~/.zshrc and you're good to go"
else
    echo "Run this script when you have them installed"
fi

