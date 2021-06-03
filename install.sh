#!/bin/bash
set -u

abort() {
  printf "%s\n" "$@"
  exit 1
}

if [ -z "${BASH_VERSION:-}" ]; then
  abort "Bash is required to interpret this script."
fi

# Check if script is run non-interactively (e.g. CI)
# If it is run non-interactively we should not prompt for passwords.
if [[ ! -t 0 || -n "${CI-}" ]]; then
  NONINTERACTIVE=1
fi

# First check OS.
OS="$(uname)"
if [[ "$OS" == "Linux" ]]; then
  AID_ON_LINUX=1
elif [[ "$OS" != "Darwin" ]]; then
  abort "The installation script is only supported on macOS and Linux."
fi

# check the channel argument
AID_ON_EDGE=0
CHANNEL="${1:-default}"
if [[ "$CHANNEL" == "edge" ]]; then
  AID_ON_EDGE=1
fi

# Initialise constants
# string formatters
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"


have_sudo_access() {
  local -a args
  if [[ -n "${SUDO_ASKPASS-}" ]]; then
    args=("-A")
  elif [[ -n "${NONINTERACTIVE-}" ]]; then
    args=("-n")
  fi

  if [[ -z "${HAVE_SUDO_ACCESS-}" ]]; then
    if [[ -n "${args[*]-}" ]]; then
      SUDO="/usr/bin/sudo ${args[*]}"
    else
      SUDO="/usr/bin/sudo"
    fi
    if [[ -n "${NONINTERACTIVE-}" ]]; then
      ${SUDO} -l mkdir &>/dev/null
    else
      ${SUDO} -v && ${SUDO} -l mkdir &>/dev/null
    fi
    HAVE_SUDO_ACCESS="$?"
  fi

  if [[ -z "${AID_ON_LINUX-}" ]] && [[ "$HAVE_SUDO_ACCESS" -ne 0 ]]; then
    abort "Need sudo access on macOS (e.g. the user $USER needs to be an Administrator)!"
  fi

  return "$HAVE_SUDO_ACCESS"
}

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

execute() {
  if ! "$@"; then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

execute_sudo() {
  local -a args=("$@")
  if have_sudo_access; then
    if [[ -n "${SUDO_ASKPASS-}" ]]; then
      args=("-A" "${args[@]}")
    fi
    ohai "/usr/bin/sudo" "${args[@]}"
    execute "/usr/bin/sudo" "${args[@]}"
  else
    ohai "${args[@]}"
    execute "${args[@]}"
  fi
}

getc() {
  local save_state
  save_state=$(/bin/stty -g)
  /bin/stty raw -echo
  IFS= read -r -n 1 -d '' "$@"
  /bin/stty "$save_state"
}

ring_bell() {
  # Use the shell's audible bell.
  if [[ -t 1 ]]; then
    printf "\a"
  fi
}

wait_for_user() {
  local c
  echo
  echo "Press RETURN to continue or any other key to abort"
  getc c
  # we test for \r and \n because some stuff does \r instead
  if ! [[ "$c" == $'\r' || "$c" == $'\n' ]]; then
    exit 1
  fi
}

get_permission() {
  $STAT "%A" "$1"
}

user_only_chmod() {
  [[ -d "$1" ]] && [[ "$(get_permission "$1")" != "755" ]]
}

exists_but_not_writable() {
  [[ -e "$1" ]] && ! [[ -r "$1" && -w "$1" && -x "$1" ]]
}

get_owner() {
  $STAT "%u" "$1"
}

file_not_owned() {
  [[ "$(get_owner "$1")" != "$(id -u)" ]]
}

get_group() {
  $STAT "%g" "$1"
}

file_not_grpowned() {
  [[ " $(id -G "$USER") " != *" $(get_group "$1") "*  ]]
}

if ! command -v curl >/dev/null; then
    abort "$(cat <<EOABORT
You must install cURL before installing Homebrew. See:
  ${tty_underline}https://aid.autoai.org/docs/getting-started/installation${tty_reset}
EOABORT
)"
fi

ohai 'Checking for `sudo` access (which may request your password).'
have_sudo_access
ohai '`sudo` Access Granted'

ohai "Downloading and installing AID..."
(
    cd /usr/local/bin >/dev/null || return
    if [[ "$AID_ON_EDGE" == 1 ]]; then 
        if [[ "$AID_ON_LINUX" == 1 ]]; then
            ohai "Going to install AID (edge, linux)..."
            execute_sudo curl https://releases.autoai.org/aid/components/cmd/tui/aid-linux --output aid
        else
            ohai "Going to install AID (edge, macOS)..."
            execute_sudo curl https://releases.autoai.org/aid/components/cmd/tui/aid-macOS --output aid
        fi
    else
        if [[ "$AID_ON_LINUX" == 1 ]]; then
            ohai "Going to install AID (stable, linux)..."
            execute_sudo curl -L https://github.com/eth-library-lab/aid-releases/releases/download/v1.3/aid-linux --output aid
        else
            ohai "Going to install AID (stable, macOS)..."
            execute_sudo curl -L https://github.com/eth-library-lab/aid-releases/releases/download/v1.3/aid-macOS --output aid
        fi
    fi
    execute_sudo chmod +x aid
)

ohai "Finished!"