# LCARS Zsh Theme — TNG-inspired (clean baseline)

autoload -U colors && colors
setopt PROMPT_SUBST
setopt TRANSIENT_RPROMPT

# ----- Palette -----
LC_ORANGE="%F{214}"
LC_PINK="%F{205}"
LC_PINK_INPUT="%F{218}"
LC_PINK_IDLE="%F{182}"
LC_PURPLE="%F{141}"
LC_BLUE="%F{81}"
LC_DIM="%F{242}"
LC_RESET="%f"

# ----- Layout -----
: ${LCARS_W:=18}
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

_lcars_block_color() {
  local color="$1"
  local label="$2"
  print -n "${color}$(_lcars_pad "$label")${LC_RESET}"
}

_lcars_label() { print -n "${LC_ORANGE}$1${LC_RESET}"; }

# ----- Git -----
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats " ${LC_PURPLE}${LCARS_GIT_BRANCH_ICON} %b${LC_RESET}"

_lcars_git_dirty() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return 0
  command git diff --quiet --cached || { print -n "${LC_PINK}•${LC_RESET}"; return 0; }
  command git diff --quiet || { print -n "${LC_PINK}•${LC_RESET}"; return 0; }
  return 0
}

# ----- Hooks -----
autoload -Uz add-zsh-hook
typeset -g LCARS_INPUT_ACTIVE=0

lcars_vcs_precmd() { vcs_info }
add-zsh-hook precmd lcars_vcs_precmd

lcars_precmd_dim() {
  LCARS_INPUT_ACTIVE=0
  print -Pn "${LC_PINK_IDLE}"
}
add-zsh-hook precmd lcars_precmd_dim

lcars_zle_line_init() {
  if (( LCARS_INPUT_ACTIVE == 0 )); then
    LCARS_INPUT_ACTIVE=1
    print -Pn "${LC_PINK_INPUT}"
  fi
}
zle -N zle-line-init lcars_zle_line_init

lcars_zle_keymap_select() {
  if (( LCARS_INPUT_ACTIVE == 0 )); then
    LCARS_INPUT_ACTIVE=1
    print -Pn "${LC_PINK_INPUT}"
  fi
  zle reset-prompt
}
zle -N zle-keymap-select lcars_zle_keymap_select

# ----- Status -----
_lcars_status() {
  local code=$?
  [[ $code -ne 0 ]] && print -n "${LC_PINK}ERR ${code}${LC_RESET} "
}

# ----- Prompt -----
RPROMPT=''

PROMPT='
$(_lcars_label "LCARS 47")${LC_DIM} | %* / NCC-1701-D${LC_RESET} $(_lcars_status)
$(_lcars_block_color "${LC_BLUE}" " NAV SYS") ${LC_BLUE}%~${LC_RESET}${vcs_info_msg_0_}$(_lcars_git_dirty)
$(_lcars_block_color "${LC_PINK}" " COMMAND") ${LC_PINK}${LCARS_PROMPT_CHAR} ${LC_PINK_IDLE}'

# ===== LCARS COMMANDS =====
lcars_info() {
  print ""
  print -P "${LC_ORANGE}LCARS SYSTEM STATUS${LC_RESET}"
  print -P "${LC_DIM}────────────────────────${LC_RESET}"
  print -P "${LC_PINK}Shell:${LC_RESET}        $SHELL"
  print -P "${LC_PINK}Zsh:${LC_RESET}          $ZSH_VERSION"
  print -P "${LC_PINK}Location:${LC_RESET}     %~"
  print -P "${LC_PINK}Time:${LC_RESET}         %*"
  print ""
}

lcars_scan() {
  print -P "${LC_ORANGE}SCANNING LOCAL SYSTEMS…${LC_RESET}"
  sleep 0.2
  print -P "${LC_PINK}LOCATION:${LC_RESET}  %~"
  print -P "${LC_PINK}TIME:${LC_RESET}      %*"
  print ""
}

nav_status() {
  print -P "${LC_ORANGE}NAVIGATION STATUS${LC_RESET}"
  print -P "${LC_BLUE}CURRENT SECTOR:${LC_RESET} %~"
  print ""
}

git_ops() {
  git rev-parse --is-inside-work-tree &>/dev/null || {
    print -P "${LC_PINK}NO ACTIVE REPOSITORY${LC_RESET}"
    return
  }
  print -P "${LC_ORANGE}GIT OPERATIONS${LC_RESET}"
  print -P "${LC_PINK}BRANCH:${LC_RESET}   $(git branch --show-current)"
  print ""
}

bridge_status() {
  print ""
  print -P "${LC_ORANGE}LCARS BRIDGE STATUS${LC_RESET}"
  nav_status
  git_ops
}

lcars_commands() {
  print ""
  print -P "${LC_ORANGE}LCARS COMMAND DIRECTORY${LC_RESET}"
  print ""
  print "  info     – system diagnostics"
  print "  scan     – live system scan"
  print "  nav      – navigation status"
  print "  ops      – git operations"
  print "  bridge   – full bridge readout"
  print ""
}

# ===== ORIGINAL ENTERPRISE =====
lcars_enterprise() {
  print -P "${LC_DIM}   ___-___${LC_RESET}  ${LC_BLUE}o==o======${LC_RESET}   ${LC_DIM}.   .   .   .   .${LC_RESET}"
  print -P "${LC_DIM}===========${LC_RESET} ${LC_BLUE}||//${LC_RESET}"
  print -P "${LC_DIM}        \\\\ \\\\${LC_RESET} ${LC_BLUE}|//__${LC_RESET}"
  print -P "${LC_DIM}        #_______/${LC_RESET}"
  print -P "${LC_DIM}                 NCC-1701-D${LC_RESET}"
}

# ===== BOOT (ONCE) =====
lcars_boot() {
  [[ $- != *i* ]] && return
  [[ -n "${LCARS_BOOT_SHOWN:-}" ]] && return
  export LCARS_BOOT_SHOWN=1
  print ""
  print -P "${LC_ORANGE}LCARS 47 INITIALIZING…${LC_RESET}"
  lcars_enterprise
  print ""
}

lcars_boot

# ----- Aliases -----
alias info=lcars_info
alias scan=lcars_scan
alias nav=nav_status
alias ops=git_ops
alias bridge=bridge_status
alias cmds=lcars_commands
