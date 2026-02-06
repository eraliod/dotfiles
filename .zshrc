# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

###############################################################################
# Oh My Zsh Settings
###############################################################################

# Path to oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Custom folder for oh-my-zsh plugins managed by brew
ZSH_CUSTOM=$(brew --prefix)/share

# Which plugins would you like to load?
plugins=(
	aliases
	command-not-found
	git
	docker
)

# For plugins managed by brew, source directly as custom path does not work with the symlinks
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source $ZSH/oh-my-zsh.sh

###############################################################################
# PATH Updates
###############################################################################

# Add pixi to the path
export PATH="$HOME/.pixi/bin:$PATH"

###############################################################################
# Autocompletion Settings
###############################################################################

# pixi
eval "$(pixi completion --shell zsh)"

# fzf key bindings
eval "$(fzf --zsh)"

# Terraform
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# Terramate
complete -o nospace -C /opt/homebrew/bin/terramate terramate

# Terragrunt
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terragrunt terragrunt

###############################################################################
# Terramate Settings
###############################################################################
export TM_DISABLE_SAFEGUARDS=git-untracked,git-uncommitted,git-out-of-sync

###############################################################################
# Functions
###############################################################################

# function to easily pick aws profile from ~/.aws/config file
ap () {
  profile=${1:-}
  if [[ -z "$profile" ]]
  then
    profile=$(aws configure list-profiles | fzf)
  fi
  export AWS_PROFILE="$profile"
}

# function to easily pick databricks profile from ~/.databrickscfg file
dp () {
  profile=${1:-}
  if [[ -z "$profile" ]]
  then
    profile=$(databricks auth profiles | awk 'NR>1 {print $1}' | fzf)
  fi
  export DATABRICKS_CONFIG_PROFILE="$profile"
}

# function deletes all local branches not present in remote
gbdg () {
    git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -n 1 echo git branch -D
}

# function to create a uuid
get-uuid() {
    uuidgen | tr '[:upper:]' '[:lower:]'
}

###############################################################################
# Powerlevel10k Configuration
###############################################################################

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# To customize prompt, run `p10k configure` or edit ~/dotfiles/.p10k.zsh.
[[ ! -f ~/dotfiles/.p10k.zsh ]] || source ~/dotfiles/.p10k.zsh

###############################################################################
# Dotfiles
###############################################################################
for file in ~/.{private,aliases}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

eval $(thefuck --alias)
