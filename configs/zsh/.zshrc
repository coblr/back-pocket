# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Makes repository status check for large repositories much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git)

source $ZSH/oh-my-zsh.sh

######################
# USER CONFIGURATION #
######################

# Use oh-my-posh for theming
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/coblr.omp.json)"

# Preferred editor for local and remote sessions
export EDITOR='nvim'

# prevent corepack from adding packageManager field to package.json automatically
export COREPACK_ENABLE_AUTO_PIN=0

# -----------------
# PATH MODIFIERS
# -----------------

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# NVM setup for managing NodeJS versions
export NVM_DIR="$HOME/.nvm"
PATH="$(find $NVM_DIR/versions/node -maxdepth 1 -name "v$(cat $NVM_DIR/alias/default)*" | sort -V | tail -1)/bin:$PATH"

# Lazy-load nvm — only sources when you run nvm or cd into a dir with .nvmrc
nvm() {
  unfunction nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm "$@"
}
autoload -U add-zsh-hook
_nvm_auto_use() {
  if [[ -f .nvmrc ]] && ! typeset -f nvm | grep -q 'NVM_DIR' 2>/dev/null; then
    unfunction nvm 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm use
  fi
}
add-zsh-hook chpwd _nvm_auto_use

# PNPM setup
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# pyenv/python setup — lazy-loaded since python is rarely used
export PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/versions/$(cat $PYENV_ROOT/version)/bin:$PYENV_ROOT/bin:$PATH"

pyenv() {
  unfunction pyenv
  eval "$(command pyenv init - -zsh)"
  pyenv "$@"
}

# SDKMAN should be after all path modifiers so that it always adds its stuff at the end
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

#####################
 # COMMAND ALIASES #
#####################

# lists all the files and directories (except . and ..) in a director
alias lf='ls -A1'

# makes the aerospace panes back to original/default sizing
alias bal='aerospace balance-sizes'

# ------------
# AI Aliases
# ------------

# Adds a custom system prompt to Claude Code to improve actions, behavior and personality
alias claude='claude --append-system-prompt "$(cat ~/.claude/system-prompt.txt)"'

# Starts Serena MCP server and adds it to Claude for the current directory
function serena-activate(){
  claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd) --enable-web-dashboard False
}

# --------------------
# Git Aliases
# --------------------

# git aliases
alias main="git checkout main"

# lists branches without putting into separate program
alias lsbranch="git branch --list | cat"

# Shows all the files that have changed in this branch (across all commits)
alias gdif='git diff --name-only "$(git merge-base main HEAD)"'

# Soft resets all commits on a branch from when it diverged from main, leaving
# all changes in place ready for a different commit strategy.
# Example: squash
function squash() {
  git reset $(git merge-base main $(git branch --show-current)) --soft
}

# PNPM aliases
alias clean="rm -rf node_modules && pnpm -r exec rm -rf node_modules"
alias cleanstall="pnpm clean && pnpm install"

# ------------------
# WORKTREE ALIASES
# ------------------

# Create a new local bare repo with main worktree
#
# Example:
# mkforest my-new-project
function mkforest() {
  local folder_name="$1"

  if [[ -z "$folder_name" ]]; then
    echo "❌ Error: Please provide a folder name"
    echo "Usage: mkforest <folder-name>"
    return 1
  fi

  if [[ -d "$folder_name" ]]; then
    echo "❌ Error: Folder '$folder_name' already exists"
    return 1
  fi

  echo "📁 Creating folder: $folder_name"
  mkdir "$folder_name" && cd "$folder_name"

  echo "🔧 Initializing bare git repo..."
  git init --bare .git

  echo "🌳 Creating main worktree..."
  git worktree add main

  echo "✅ Done!"
  echo "🚀 Launching you into ${folder_name}/main, the 'main' worktree..."
  cd main
}

# Clone a repo as a bare repo with main worktree (keeps git internals contained in .git/)
#
# Example:
# mkclone git@github.com:organization/my-repo.git
function mkclone() {
  local repo_url="$1"

  if [[ -z "$repo_url" ]]; then
    echo "❌ Error: Please provide a repository URL"
    echo "Usage: mkclone <repo-url>"
    return 1
  fi

  local repo_name=$(basename "$repo_url" .git)

  echo "🔄 Cloning $repo_url as bare repo..."
  mkdir "$repo_name" && cd "$repo_name"
  git clone --bare "$repo_url" .git

  # Set up the fetch refspec so remote branches are tracked
  git config --local remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
  git fetch origin

  echo "🌳 Creating main worktree..."
  git worktree add main

  # Set up upstream tracking for main
  cd main
  git branch --set-upstream-to=origin/main main

  echo "✅ Done!"
  echo "🚀 You're now in ${repo_name}/main, the 'main' worktree..."
}

# Lists all the trees in a repo
alias lstree="git worktree list | awk 'NR==1 {root=\$1} NR>1 {sub(root\"/\", \"\", \$1); print \$1}'"

# Alias for creating a git worktree for a given branch. This function creates
# worktrees within the project directory structure alongside the main folder.
# Whether you run it from main or from a branch worktree, it will create the new
# worktree in the correct location. Once the tree is created, it'll cd into it.
#
# /Development/project-name (bare repo)
#   |- main/
#   |- feat/
#     |- my-feature/
#   |- other-branch/
#
# Additionally, this will also copy over any dot files into the new tree.
# If the file already exists, it'll ask whether to replace or skip.
#
# Example:
# mktree feat/my-feature
function mktree() {
  local branch_name="$1"
  local current_dir=$(basename "$PWD")
  local project_root

  # Find the project root by looking for a bare .git directory or main worktree
  local search_path="$PWD"
  while [[ "$search_path" != "/" ]]; do
    if [[ -d "$search_path/.git" && -d "$search_path/main" ]]; then
      project_root="$search_path"
      break
    fi
    search_path="$(dirname "$search_path")"
  done

  if [[ -z "$project_root" ]]; then
    echo "❌ Error: Could not find project root with bare .git directory"
    return 1
  fi

  # Set up worktree path within project root
  local worktree_path="$project_root/$branch_name"

  # Fetch latest refs so we can detect remote branches
  echo "🔄 Fetching latest from origin..."
  git -C "$project_root" fetch origin --quiet

  echo "🔍 Attempting to checkout branch: $branch_name"
  if git -C "$project_root" show-ref --verify --quiet refs/heads/"$branch_name"; then
    # Local branch exists
    echo "📋 Checking out existing local branch: $branch_name"
    git -C "$project_root" worktree add "$worktree_path" "$branch_name"
  elif git -C "$project_root" show-ref --verify --quiet refs/remotes/origin/"$branch_name"; then
    # Remote branch exists but no local branch
    echo "📋 Checking out existing remote branch: $branch_name"
    git -C "$project_root" worktree add -b "$branch_name" "$worktree_path" "origin/$branch_name"
    # Set upstream tracking
    git -C "$worktree_path" branch --set-upstream-to="origin/$branch_name" "$branch_name"
  else
    # Neither exists, create new
    echo "🆕 Creating new branch: $branch_name"
    git -C "$project_root" worktree add -b "$branch_name" "$worktree_path"
  fi

  # Copy essential dot files that aren't committed but are needed for development
  echo "📁 Copying essential dot files from main project..."

  # Only copy specific files that are important for development but not committed
  local essential_files=()

  # Check for environment files and .npmrc files throughout the main worktree (excluding node_modules)
  local env_and_config_files=($(find "$project_root/main" -name ".env*" -o -name ".npmrc" | grep -v node_modules))
  essential_files+=("${env_and_config_files[@]}")

  if [[ ${#essential_files[@]} -gt 0 ]]; then
    local copied_count=0
    local skipped_count=0

    for dot_file in "${essential_files[@]}"; do
      local relative_path="${dot_file#$project_root/main/}"
      local target_path="$worktree_path/$relative_path"
      local target_dir="$(dirname "$target_path")"

      if [[ ! -e "$target_path" ]]; then
        # Create target directory if it doesn't exist
        [[ ! -d "$target_dir" ]] && mkdir -p "$target_dir"
        cp "$dot_file" "$target_path"
        echo "  ✅ $relative_path"
        ((copied_count++))
      else
        ((skipped_count++))
      fi
    done

    if [[ $copied_count -gt 0 ]]; then
      echo "✅ Copied $copied_count essential files"
    fi

    if [[ $skipped_count -gt 0 ]]; then
      echo "⏭️  Skipped $skipped_count existing files"
    fi
  else
    echo "⚠️  No essential dot files found in main project"
  fi

  # Navigate to worktree
  cd "$worktree_path"
}

# Alias for removing a worktree and assocated branch
#
# Example:
# rmtree feat/my-feature-branch
function rmtree() {
  local branch_name="$1"
  echo "🌳 Removing worktree for $branch_name..."
  git worktree remove "$branch_name" && git branch -D "$1"
  echo "✅ Done!"
}

# Completion for rmtree - suggests existing worktrees
_rmtree() {
  local worktrees
  worktrees=(${(f)"$(git worktree list 2>/dev/null | awk 'NR>1 {gsub(/[\[\]]/, "", $3); print $3}')"})
  _describe 'worktree' worktrees
}
compdef _rmtree rmtree

# -----------------
# Machine-specific
# -----------------
# Source local overrides (work-specific env vars, aliases, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
