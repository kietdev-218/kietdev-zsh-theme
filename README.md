# kietdev-zsh-theme
Personalized Zsh Theme
# KietDev ZSH Theme

A modern ZSH theme built upon the popular robbyrussell theme, enhanced with comprehensive Python environment detection, advanced git status tracking, and a clean header layout.

## ✨ Features

### 🎨 **Enhanced Header Layout**
- **User@Host format**: `username@host` display
- **Bracketed directory**: `[~/projects/myapp]` with 3-level depth
- **Git display**: Branch info in parentheses `(branch)`
- **Right-aligned information**: Python environment and timestamp
- **Dynamic width**: Auto-fills terminal width with separators

### 🌿 **Advanced Git Integration**
- **Branch relationships**: Local→remote when tracking different branches
- **Push/Pull tracking**: 
  - `↑3` commits ahead (red)
  - `↓2` commits behind (green)
- **Working tree status**: 
  - `✔` Clean repository (green)
  - `✗` Modified files (yellow)
- **Upstream display**: Remote branch when different from local

### 🐍 **Comprehensive Python Environment Support**
- **Conda environments**: `(conda:tensorflow)` - active conda environments
- **Conda base**: `(conda:base)` - base environment
- **Pyenv**: `(pyenv:3.9.7)` - virtual environments and Python versions
- **Pipenv**: `(pipenv:myproject)` - pipenv project environments
- **Poetry**: `(poetry:myproject)` - poetry-managed environments  
- **Virtualenv**: `(venv:myenv)` - standard Python virtual environments
- **Global Python**: `(py:3.9.7)` - pyenv-managed global Python versions

### 🕐 **Time Display**
- **Timezone format**: `UTC +7`
- **Real-time updates**: Current time in header
- **Date format**: `DD/MM HH:MM:SS` with timezone

### 🎯 **Visual Features**
- **Color scheme**: 
  - Username: bold blue
  - Hostname: bold magenta
  - Directory: cyan in brackets
  - Git local branch: red
  - Git remote branch: green
  - Environment: light cyan
- **Status-aware prompt**: Green arrow (success), red arrow (failure)
- **Minimal design**: Maximum information density

## 📋 Display Format

```
username@host [~/projects/myapp] (main→origin) ✔ ↑2 ————————— (conda:tensorflow) 07/02 17:09:49 UTC +7
❯ 
```

**Elements:**
- `username@host` - User identification
- `[~/projects/myapp]` - Working directory (3 levels)
- `(main→origin) ✔ ↑2` - Git branch, status, push/pull counts
- `————————————` - Dynamic separator
- `(conda:tensorflow)` - Active Python environment
- `07/02 17:09:49 UTC +7` - Timestamp with timezone
- `❯` - Command prompt (status-aware color)

## 📦 Installation

1. **Clone project**:
   ```bash
   git clone --branch v1.0.0 --single-branch https://github.com/kietdev-218/kietdev-zsh-theme.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/kietdev"
   ```

2. **Update your `.zshrc`**:
   ```bash
   ZSH_THEME="kietdev-zsh-theme/kietdev"
   ```

3. **Restart your shell**:
   ```bash
   source ~/.zshrc
   ```

## 🔧 Requirements

- **ZSH shell** with Oh My Zsh framework
- **Git** for repository status detection
- **Python environment managers** (optional): conda, pyenv, pipenv, poetry

## ⚡ Performance

### **Git Operations**
The theme performs these git commands for each prompt:
- Repository detection
- Branch name resolution
- Upstream branch checking
- Ahead/behind commit counting
- Working tree status scanning

### **Performance Factors**
- Repository size and complexity
- Number of untracked files
- Git history depth
- Storage type (SSD vs HDD vs network)

## 🔄 Environment Detection Priority

The theme checks for Python environments in this order:

1. **Conda**: `CONDA_DEFAULT_ENV` environment variable
2. **Pyenv virtual environments**: `PYENV_VIRTUAL_ENV` 
3. **Pyenv Python versions**: `PYENV_VERSION`
4. **Pipenv**: `PIPENV_ACTIVE` flag
5. **Poetry**: `POETRY_ACTIVE` flag  
6. **Standard virtualenv**: `VIRTUAL_ENV` variable
7. **Global Python**: `pyenv version-name` command (fallback)

## 🎨 Customization

### **Color Scheme**
```bash
# Virtual environment colors (light cyan)
ZSH_THEME_VIRTUALENV_PREFIX="%{$FG[116]%}("
ZSH_THEME_VIRTUALENV_SUFFIX=") %{$reset_color%}"

# Git status colors
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[yellow]%}✗%{$fg[blue]%})"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg[green]%}✔%{$fg[blue]%})"
```

### **Environment Controls**
The theme automatically disables default prompts:
```bash
export VIRTUAL_ENV_DISABLE_PROMPT=1
export CONDA_CHANGEPS1=false
```

## 🛠️ Built Upon robbyrussell

Extends robbyrussell theme with:
- **Enhanced information**: Python environments, timezone, push/pull tracking
- **Advanced git integration**: Upstream branch relationships, commit counts
- **Header layout**: Right-aligned information display
- **Improved visual hierarchy**: Color-coded elements

Maintains robbyrussell core:
- **Arrow prompt**: Status-aware command indicator
- **Git integration**: Branch and status display
- **Lightweight operation**: Performance-focused design
- **Familiar interface**: Easy migration path

## 📄 License

MIT License
