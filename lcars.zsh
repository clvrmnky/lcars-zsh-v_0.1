# lcars.zsh — pure Zsh LCARS-inspired prompt (TNG vibe)
# No dependencies. Works in macOS Terminal.app.

autoload -U colors && colors
setopt PROMPT_SUBST
setopt TRANSIENT_RPROMPT

# ----- Palette (tweak as desired) -----
LC_ORANGE="%F{214}"
LC_PINK="%F{205}"
LC_PURPLE="%F{141}"
LC_BLUE="%F{81}"
LC_DIM="%F{242}"
LC_RESET="%f"

# Left panel width
: ${LCARS_W:=18}

# Symbols
: ${LCARS_PROMPT_CHAR:="❯"}
: ${LCARS_GIT_BRANCH_ICON:=""}

# ----- Helpers -----
_lcars_pad() {
  local label="$1"
  local w=${LCARS_W}
  local len=${#label}
  local pad=$(( w - len ))
  (( pad < 0 )) && label="${label[1,w]}" && pad=0
  printf "%s%*s" "$label" "$pad" ""
}

_lcars_block() {
  # Orange “panel” block with padded label
  print -n "${LC_ORANGE}$(_lcars_pad "$1")${LC_RESET}"
}

# ----- Git (fast + built-in) -----
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats " ${LC_PURPLE}${LCARS_GIT_BRANCH_ICON} %b${LC_RESET}"
zstyle ':vcs_info:git:*' actionformats " ${LC_PURPLE}${LCARS_GIT_BRANCH_ICON} %b${LC_RESET} ${LC_PINK}(%a)${LC_RESET}"

_lcars_git_dirty() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return 0
  command git diff --no-ext-diff --quiet --ignore-submodules --cached 2>/dev/null || { print -n "${LC_PINK}•${LC_RESET}"; return 0; }
  command git diff --no-ext-diff --quiet --ignore-submodules 2>/dev/null || { print -n "${LC_PINK}•${LC_RESET}"; return 0; }
  return 0
}

precmd() { vcs_info }

# ----- Prompt -----
_lcars_status() {
  local code=$?
  if [[ $code -ne 0 ]]; then
    print -n "${LC_PINK}ERR ${code}${LC_RESET} "
  fi
}

# Right prompt: time + operator
RPROMPT='${LC_DIM}%*  %n@%m${LC_RESET}'

# Two-line LCARS layout
PROMPT='
$(_lcars_block " LCARS 47") $(_lcars_status)
$(_lcars_block " NAV SYS") ${LC_BLUE}%~${LC_RESET}${vcs_info_msg_0_}$(_lcars_git_dirty)
$(_lcars_block " COMMAND") ${LC_ORANGE}${LCARS_PROMPT_CHAR}${LC_RESET} '
