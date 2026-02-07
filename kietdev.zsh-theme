export VIRTUAL_ENV_DISABLE_PROMPT=1
export CONDA_CHANGEPS1=false

# Performance optimization variables
typeset -g _KIETDEV_CACHE_PWD=""
typeset -g _KIETDEV_CACHE_GIT_DIR=""
typeset -g _KIETDEV_CACHE_GIT_INFO=""
typeset -g _KIETDEV_CACHE_VENV_INFO=""
typeset -g _KIETDEV_CACHE_VENV_KEY=""
typeset -g _KIETDEV_CACHE_TIME=""
typeset -g _KIETDEV_CACHE_USER_HOST=""
typeset -g _KIETDEV_CACHE_TIMEZONE=""
typeset -gi _KIETDEV_CACHE_TIMESTAMP=0
typeset -gi _KIETDEV_GIT_ASYNC_PID=0
typeset -g _KIETDEV_GIT_ASYNC_RESULT=""

_PROMPT_PREFIX_='%B❯%b'
_PROMPT_STATUS_='%(?:%{$fg_bold[green]%}$_PROMPT_PREFIX_:%{$fg_bold[red]%}$_PROMPT_PREFIX_)'
_VIRTUALENV_INFO_='$(virtualenv_info_cached)'

ZSH_THEME_HOSTNAME_PREFIX="%{$fg_bold[magenta]%}host:(%{$fg[yellow]%}"
ZSH_THEME_HOSTNAME_SUFFIX="%{$fg_bold[magenta]%})%{$reset_color%}"

ZSH_THEME_USER_PREFIX="%{$fg_bold[blue]%}user:(%{$fg[cyan]%}"
ZSH_THEME_USER_SUFFIX="%{$fg_bold[blue]%})%{$reset_color%}"

ZSH_THEME_VIRTUALENV_PREFIX="%{$FG[116]%}("
ZSH_THEME_VIRTUALENV_SUFFIX=") %{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[yellow]%}✗%{$fg[blue]%})"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%{$fg[blue]%})"

function postcmd_newline() {
  # add a newline after every prompt except the first line 
  precmd() {
    precmd() {
      print "" 
    }
  } 
}

function get_current_dir() {
  echo "[%{$fg[cyan]%}%3~%{$reset_color%}]"
}

function virtualenv_info_cached() {
  # Cache virtual environment info since it doesn't change frequently
  local current_venv_key="${CONDA_DEFAULT_ENV:-}:${PYENV_VIRTUAL_ENV:-}:${PYENV_VERSION:-}:${PIPENV_ACTIVE:-}:${POETRY_ACTIVE:-}:${VIRTUAL_ENV:-}"
  
  if [[ "$current_venv_key" != "$_KIETDEV_CACHE_VENV_KEY" ]]; then
    _KIETDEV_CACHE_VENV_KEY="$current_venv_key"
    _KIETDEV_CACHE_VENV_INFO="$(virtualenv_info_compute)"
  fi
  
  echo "$_KIETDEV_CACHE_VENV_INFO"
}

function virtualenv_info_compute() {
  local env_name=""
  
  # Check for conda environments - optimized order (most common first)
  if [[ -n ${CONDA_DEFAULT_ENV} ]]; then
    if [[ ${CONDA_DEFAULT_ENV} == "base" ]]; then
      env_name="conda:base"
    else
      env_name="conda:${CONDA_DEFAULT_ENV}"
    fi
  elif [[ -n ${CONDA_PREFIX} ]]; then
    # Extract environment name from conda prefix path
    local conda_env_path="${CONDA_PREFIX}"
    if [[ $conda_env_path == */envs/* ]]; then
      env_name="conda:$(basename ${conda_env_path})"
    elif [[ $conda_env_path == */miniconda* ]] || [[ $conda_env_path == */anaconda* ]]; then
      env_name="conda:base"
    else
      env_name="conda:$(basename ${conda_env_path})"
    fi
  
  # Check for pyenv virtual environments
  elif [[ -n ${PYENV_VIRTUAL_ENV} ]]; then
    env_name="pyenv:$(basename ${PYENV_VIRTUAL_ENV})"
  elif [[ -n ${PYENV_VERSION} ]] && [[ ${PYENV_VERSION} != "system" ]]; then
    env_name="pyenv:${PYENV_VERSION}"
  
  # Standard virtualenv/venv (moved up for performance)
  elif [[ -n ${VIRTUAL_ENV} ]]; then
    # Check context to determine if it's pipenv/poetry
    if [[ -n ${PIPENV_ACTIVE} ]]; then
      env_name="pipenv:$(basename ${VIRTUAL_ENV})"
    elif [[ -n ${POETRY_ACTIVE} ]]; then
      env_name="poetry:$(basename ${VIRTUAL_ENV})"
    else
      env_name="venv:$(basename ${VIRTUAL_ENV})"
    fi
  
  # Check for Python version manager (pyenv global version) - most expensive, run last
  elif command -v pyenv >/dev/null 2>&1; then
    local pyenv_version="$(pyenv version-name 2>/dev/null)"
    if [[ -n $pyenv_version ]] && [[ $pyenv_version != "system" ]]; then
      env_name="py:${pyenv_version}"
    fi
  fi
  
  # Display the environment info if found
  if [[ -n $env_name ]]; then
    echo "${ZSH_THEME_VIRTUALENV_PREFIX}${env_name}${ZSH_THEME_VIRTUALENV_SUFFIX}"
  fi
}

function git_prompt_info() {
  # Use cached git info for performance
  local current_pwd="$PWD"
  
  # Quick exit if not in git repo (cached check)
  if [[ ! -d .git ]] && ! git rev-parse --git-dir >/dev/null 2>&1; then
    _KIETDEV_CACHE_GIT_INFO=""
    return
  fi
  
  local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
  [[ -n $git_dir ]] || return
  
  # Cache hit: same directory and git repo
  if [[ "$current_pwd" == "$_KIETDEV_CACHE_PWD" ]] && [[ "$git_dir" == "$_KIETDEV_CACHE_GIT_DIR" ]]; then
    # Check if we should update due to time (refresh every 5 seconds for git status)
    local current_time=$EPOCHSECONDS
    if (( current_time - _KIETDEV_CACHE_TIMESTAMP < 5 )) && [[ -n "$_KIETDEV_CACHE_GIT_INFO" ]]; then
      echo "$_KIETDEV_CACHE_GIT_INFO"
      return
    fi
  fi
  
  # Update cache metadata
  _KIETDEV_CACHE_PWD="$current_pwd"
  _KIETDEV_CACHE_GIT_DIR="$git_dir"
  
  # Check if async result is ready
  if [[ -n "$_KIETDEV_GIT_ASYNC_RESULT" ]]; then
    _KIETDEV_CACHE_GIT_INFO="$_KIETDEV_GIT_ASYNC_RESULT"
    _KIETDEV_GIT_ASYNC_RESULT=""
    _KIETDEV_GIT_ASYNC_PID=0
    _KIETDEV_CACHE_TIMESTAMP=$EPOCHSECONDS
    echo "$_KIETDEV_CACHE_GIT_INFO"
    return
  fi
  
  # Start async git status update if not already running
  if (( _KIETDEV_GIT_ASYNC_PID == 0 )); then
    git_prompt_info_async &
    _KIETDEV_GIT_ASYNC_PID=$!
  fi
  
  # Return fast git info (full info but synchronous) for immediate display
  git_prompt_info_sync
}

function git_prompt_info_sync() {
  # Synchronous git status for immediate display - original logic
  local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
  [[ -n $git_dir ]] || return
  
  # Get current branch name
  local branch="$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)"
  [[ -n $branch ]] || return
  
  # Get upstream branch
  local upstream="$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)"
  local origin_branch=""
  if [[ -n $upstream ]]; then
    origin_branch="${upstream#origin/}"
  fi
  
  # Get ahead/behind information
  local ahead_behind="$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)"
  local behind=0
  local ahead=0
  
  if [[ -n $ahead_behind ]]; then
    behind=$(echo $ahead_behind | cut -f1)
    ahead=$(echo $ahead_behind | cut -f2)
  fi
  
  # Build status indicators
  local status_info=""
  
  # Add ahead/behind indicators (push=red, pull=green)
  [[ $ahead -gt 0 ]] && status_info+="%{$fg[red]%}↑${ahead}"
  [[ $behind -gt 0 ]] && status_info+="%{$fg[green]%}↓${behind}"
  [[ -n $status_info ]] && status_info+=" "
  
  # Build branch display: local(red) -> origin(green)
  local branch_display="%{$fg[red]%}${branch}"
  if [[ -n $origin_branch ]] && [[ $origin_branch != $branch ]]; then
    branch_display+="%{$fg[blue]%}→%{$fg[green]%}${origin_branch}"
  fi
  
  # Check if repository is dirty
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    echo "%{$fg_bold[blue]%}(${branch_display}${ZSH_THEME_GIT_PROMPT_DIRTY} ${status_info}%{$reset_color%}"
  else
    echo "%{$fg_bold[blue]%}(${branch_display}${ZSH_THEME_GIT_PROMPT_CLEAN} ${status_info}%{$reset_color%}"
  fi
}

function git_prompt_info_async() {
  # Comprehensive git status in background - same logic as sync but runs async
  local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
  [[ -n $git_dir ]] || return
  
  # Get current branch name
  local branch="$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)"
  [[ -n $branch ]] || return
  
  # Get upstream branch
  local upstream="$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)"
  local origin_branch=""
  if [[ -n $upstream ]]; then
    origin_branch="${upstream#origin/}"
  fi
  
  # Get ahead/behind information using the efficient rev-list command
  local ahead_behind="$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)"
  local behind=0
  local ahead=0
  
  if [[ -n $ahead_behind ]]; then
    behind=$(echo $ahead_behind | cut -f1)
    ahead=$(echo $ahead_behind | cut -f2)
  fi
  
  # Check if repository is dirty
  local dirty=false
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    dirty=true
  fi
  
  # Build result
  local result=""
  if [[ -n $branch ]]; then
    local branch_display="%{$fg[red]%}${branch}"
    
    # Add upstream if different
    if [[ -n $origin_branch ]] && [[ $origin_branch != $branch ]]; then
      branch_display+="%{$fg[blue]%}→%{$fg[green]%}${origin_branch}"
    fi
    
    # Build status indicators
    local status_info=""
    
    # Add ahead/behind indicators (push=red, pull=green)
    [[ $ahead -gt 0 ]] && status_info+="%{$fg[red]%}↑${ahead}"
    [[ $behind -gt 0 ]] && status_info+="%{$fg[green]%}↓${behind}"
    [[ -n $status_info ]] && status_info+=" "
    
    # Check dirty status
    if $dirty; then
      result="%{$fg_bold[blue]%}(${branch_display}${ZSH_THEME_GIT_PROMPT_DIRTY} ${status_info}%{$reset_color%}"
    else
      result="%{$fg_bold[blue]%}(${branch_display}${ZSH_THEME_GIT_PROMPT_CLEAN} ${status_info}%{$reset_color%}"
    fi
  fi
  
  _KIETDEV_GIT_ASYNC_RESULT="$result"
}

function get_user_host() {
  # Cache user@host since it rarely changes
  if [[ -z "$_KIETDEV_CACHE_USER_HOST" ]]; then
    local username=$(whoami 2>/dev/null || echo $USER)
    local hostname=$(hostname 2>/dev/null || echo $HOST)
    _KIETDEV_CACHE_USER_HOST="%{$fg_bold[blue]%}${username}%{$fg[cyan]%}@%{$fg_bold[magenta]%}${hostname}%{$reset_color%}"
  fi
  echo "$_KIETDEV_CACHE_USER_HOST"
}

function get_current_time() {
  # Cache timezone calculation as it's expensive and rarely changes
  if [[ -z "$_KIETDEV_CACHE_TIMEZONE" ]]; then
    local timezone_offset=$(date +%z)
    local hours=${timezone_offset:1:2}
    local minutes=${timezone_offset:3:2}
    local sign=${timezone_offset:0:1}
    
    # Convert to UTC format
    if [[ $minutes == "00" ]]; then
      _KIETDEV_CACHE_TIMEZONE="UTC ${sign}${hours#0}"
    else
      _KIETDEV_CACHE_TIMEZONE="UTC ${sign}${hours#0}:${minutes}"
    fi
  fi
  
  echo "$(matte_grey '%D{%d/%m %T}') $(matte_grey $_KIETDEV_CACHE_TIMEZONE) $(get_seperator)"
}

function get_seperator() {
  echo "$(matte_grey —)"
}

function top_right_corner() {
  echo "$(get_seperator)$(matte_grey ╮)"
}

function get_space() {
  local size=$1
  local space="—"
  while [[ $size -gt 0 ]]; do
    space="$space—"
    let size=$size-1
  done
  echo "$(matte_grey $space)"
}

function matte_grey() {
  echo "%{$FG[240]%}$1%{$reset_color%}"
}

function prompt_len() {
  emulate -L zsh
  local -i COLUMNS=${2:-COLUMNS}
  local -i x y=${#1} m
  if (( y )); then
    while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
      x=y
      (( y *= 2 ))
    done
    while (( y > x + 1 )); do
      (( m = x + (y - x) / 2 ))
      (( ${${(%):-$1%$m(l.x.y)}[-1]} = m ))
    done
  fi
  echo $x
}

function prompt_header() {
  # Clean up completed async processes
  kietdev_async_cleanup
  
  local left_prompt="$(get_user_host) $(get_current_dir) $(git_prompt_info)"
  local right_prompt=" $(virtualenv_info_cached) $(get_current_time)"
  local prompt_len=$(prompt_len $left_prompt$right_prompt)
  local space_size=$(( $COLUMNS - $prompt_len - 1 ))
  local space=$(get_space $space_size)

  print -rP "$left_prompt$space$right_prompt"
}

function kietdev_async_cleanup() {
  # Check if async git process is done and collect result
  if (( _KIETDEV_GIT_ASYNC_PID > 0 )); then
    if ! kill -0 $_KIETDEV_GIT_ASYNC_PID 2>/dev/null; then
      # Process is done, wait for it to clean up
      wait $_KIETDEV_GIT_ASYNC_PID 2>/dev/null
      _KIETDEV_GIT_ASYNC_PID=0
      
      # Trigger redraw if we have new git info
      if [[ -n "$_KIETDEV_GIT_ASYNC_RESULT" ]]; then
        # Update cache immediately  
        _KIETDEV_CACHE_GIT_INFO="$_KIETDEV_GIT_ASYNC_RESULT"
        _KIETDEV_CACHE_TIMESTAMP=$EPOCHSECONDS
        
        # Trigger prompt redraw if ZLE is active
        if zle; then
          zle reset-prompt
        fi
      fi
    fi
  fi
}

# Performance cleanup on directory change
function kietdev_chpwd() {
  # Clear cache when changing directories
  _KIETDEV_CACHE_PWD=""
  _KIETDEV_CACHE_GIT_DIR=""
  _KIETDEV_CACHE_GIT_INFO=""
  
  # Kill any running async process since it's for a different directory
  if (( _KIETDEV_GIT_ASYNC_PID > 0 )); then
    kill $_KIETDEV_GIT_ASYNC_PID 2>/dev/null
    wait $_KIETDEV_GIT_ASYNC_PID 2>/dev/null
    _KIETDEV_GIT_ASYNC_PID=0
    _KIETDEV_GIT_ASYNC_RESULT=""
  fi
}

postcmd_newline
alias clear="clear; postcmd_newline"

autoload -U add-zsh-hook
add-zsh-hook precmd prompt_header
add-zsh-hook precmd kietdev_async_cleanup
add-zsh-hook chpwd kietdev_chpwd
setopt prompt_subst
ZLE_RPROMPT_INDENT=0

PROMPT="$_PROMPT_STATUS_ "