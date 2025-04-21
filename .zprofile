# Set PATHS
if [ -x "/opt/homebrew/bin/brew" ]; then
    # For Apple Silicon Macs
    export PATH="/opt/homebrew/bin:$PATH"
fi

# configure fzf key bindings
eval "$(fzf --zsh)"

# function to easily pick aws profile from ~/.aws/config file
ap () {
  profile=${1:-}
  if [[ -z "$profile" ]]
  then
    profile=$(aws configure list-profiles | fzf)
  fi
  export AWS_PROFILE="$profile"
}

# Golang environment variables run if go installed with brew
if brew list go &>/dev/null; then
    export GOROOT=$(brew --prefix go)/libexec
    export GOPATH=$HOME/go
    export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH
fi

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

# terramate
export TM_DISABLE_SAFEGUARDS=git-untracked,git-uncommitted,git-out-of-sync

