#!/data/data/com.termux/files/usr/bin/bash

if [ -t 1 ]; then
  C_RESET="\033[0m"
  C_BOLD="\033[1m"
  C_DIM="\033[2m"
  C_RED="\033[31m"
  C_GREEN="\033[32m"
  C_YELLOW="\033[33m"
  C_BLUE="\033[34m"
  C_MAGENTA="\033[35m"
  C_CYAN="\033[36m"
else
  C_RESET=""
  C_BOLD=""
  C_DIM=""
  C_RED=""
  C_GREEN=""
  C_YELLOW=""
  C_BLUE=""
  C_MAGENTA=""
  C_CYAN=""
fi

ui_clear() {
  clear 2>/dev/null || true
}

ui_line() {
  printf "%b\n" "${C_CYAN}============================================================${C_RESET}"
}

ui_title() {
  ui_clear
  ui_line
  printf "%b\n" "${C_BOLD}${C_GREEN}  AgentOS Mobile Kit${C_RESET}"
  printf "%b\n" "${C_DIM}  Central Termux, GitHub e projetos locais${C_RESET}"
  ui_line
  printf "\n"
}

ui_section() {
  printf "\n%b\n" "${C_BOLD}${C_CYAN}$1${C_RESET}"
  printf "%b\n" "${C_DIM}------------------------------------------------------------${C_RESET}"
}

ui_ok() {
  printf "%b\n" "${C_GREEN}[OK]${C_RESET} $1"
}

ui_warn() {
  printf "%b\n" "${C_YELLOW}[AVISO]${C_RESET} $1"
}

ui_error() {
  printf "%b\n" "${C_RED}[ERRO]${C_RESET} $1"
}

ui_info() {
  printf "%b\n" "${C_BLUE}[INFO]${C_RESET} $1"
}

ui_pause() {
  printf "\n"
  read -r -p "Pressione ENTER para voltar..."
}

ui_prompt() {
  local label="$1"
  local value
  read -r -p "$label: " value
  printf "%s" "$value"
}

ui_prompt_back() {
  local label="$1"
  local value
  read -r -p "$label (0 para voltar): " value
  [ "$value" = "0" ] && return 1
  printf "%s" "$value"
}

ui_choose() {
  local label="$1"
  local value
  read -r -p "$label [0 voltar]: " value
  [ "$value" = "0" ] && return 1
  printf "%s" "$value"
}

ui_confirm() {
  local label="$1"
  local answer
  read -r -p "$label [s/N]: " answer
  [ "$answer" = "s" ] || [ "$answer" = "S" ]
}

ui_menu_item() {
  printf "  %b%2s%b  %s\n" "${C_GREEN}" "$1" "${C_RESET}" "$2"
}

ui_header_small() {
  printf "%b%s%b\n" "${C_BOLD}${C_MAGENTA}" "$1" "${C_RESET}"
}
