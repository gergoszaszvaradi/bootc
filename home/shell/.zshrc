# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set ZSH directory
export ZSH="$HOME/.zsh"

# Create .zsh directory
mkdir -p $ZSH
mkdir -p $ZSH/themes
mkdir -p $ZSH/plugins

# Load theme
if [ ! -d $ZSH/themes/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH/themes/powerlevel10k
fi
source $ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh

# Load plugins
if [ ! -d $ZSH/plugins/zsh-autosuggestions ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git $ZSH/plugins/zsh-autosuggestions
fi
source $ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

if [ ! -d $ZSH/plugins/fast-syntax-highlighting ]; then
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting $ZSH/plugins/fast-syntax-highlighting
fi
source $ZSH/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

if [ ! -d $ZSH/plugins/zsh-autocomplete ]; then
    git clone --depth=1 https://github.com/marlonrichert/zsh-autocomplete.git $ZSH/plugins/zsh-autocomplete
fi
source $ZSH/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# History settings
HISTSIZE=5000
HISTFILE=$ZSH/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
HISTORY_IGNORE="(fg|exit)"
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Keybinds
bindkey "^[[H"  beginning-of-line
bindkey "^[[F"  end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

bindkey -M menuselect '\e' undo

# Load .shrc
if [ -f $HOME/.shrc ]; then
    . $HOME/.shrc
fi
