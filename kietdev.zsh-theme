export VIRTUAL_ENV_DISABLE_PROMPT=1
export CONDA_CHANGEPS1=false

_PROMPT_PREFIX_='%B❯%b'
_PROMPT_STATUS_='%(?:%{$fg_bold[green]%}$_PROMPT_PREFIX_:%{$fg_bold[red]%}$_PROMPT_PREFIX_)'
_VIRTUALENV_INFO_='$(virtualenv_info)'

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

function virtualenv_info() {
  local env_name=""
  
  # Check for conda environments - try multiple methods
  if [[ -n ${CONDA_DEFAULT_ENV} ]] && [[ ${CONDA_DEFAULT_ENV} != "base" ]]; then
    env_name="conda:${CONDA_DEFAULT_ENV}"
  elif [[ -n ${CONDA_DEFAULT_ENV} ]] && [[ ${CONDA_DEFAULT_ENV} == "base" ]]; then
    # Show base environment as well, but marked as base
    env_name="conda:base"
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
  
  # Check for pipenv environments
  elif [[ -n ${PIPENV_ACTIVE} ]]; then
    env_name="pipenv:$(basename ${VIRTUAL_ENV:-pipenv})"
  
  # Check for poetry environments
  elif [[ -n ${POETRY_ACTIVE} ]]; then
    env_name="poetry:$(basename ${VIRTUAL_ENV:-poetry})"
  
  # Check for standard virtualenv/venv
  elif [[ -n ${VIRTUAL_ENV} ]]; then
    env_name="venv:$(basename ${VIRTUAL_ENV})"
  
  # Check for Python version manager (pyenv global version)
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
  # Check if we're in a git repository
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

function get_user_host() {
  local username=$(whoami)
  local hostname=$(hostname)
  echo "%{$fg_bold[blue]%}${username}%{$fg[cyan]%}@%{$fg_bold[magenta]%}${hostname}%{$reset_color%}"
}

function get_current_time() {
  local timezone_offset=$(date +%z)
  local hours=${timezone_offset:1:2}
  local minutes=${timezone_offset:3:2}
  local sign=${timezone_offset:0:1}
  
  # Convert to UTC format
  if [[ $minutes == "00" ]]; then
    local tz_display="UTC ${sign}${hours#0}"
  else
    local tz_display="UTC ${sign}${hours#0}:${minutes}"
  fi
  
  echo "$(matte_grey '%D{%d/%m %T}') $(matte_grey $tz_display) $(get_seperator)"
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
  local left_prompt="$(get_user_host) $(get_current_dir) $(git_prompt_info)"
  local right_prompt=" $(virtualenv_info) $(get_current_time)"
  local prompt_len=$(prompt_len $left_prompt$right_prompt)
  local space_size=$(( $COLUMNS - $prompt_len - 1 ))
  local space=$(get_space $space_size)

  print -rP "$left_prompt$space$right_prompt"
}

postcmd_newline
alias clear="clear; postcmd_newline"

autoload -U add-zsh-hook
add-zsh-hook precmd prompt_header
setopt prompt_subst
ZLE_RPROMPT_INDENT=0

PROMPT="$_PROMPT_STATUS_ "

autoload -U add-zsh-hook
add-zsh-hook precmd prompt_header