set -o allexport
CORE_VERSION="v2.2"

CORE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "[CORE] $CORE_VERSION ($(cd $CORE_DIR && git rev-parse --short HEAD))"

SERVICES_DIR=$(dirname $SERVICE_DIR)
set +o allexport

# COMMANDS
declare -A commands=(
  [help]=":Show this help message"
)
cmd_help() {
  print_help "" "commands"
}

# GLOBAL SUB-COMMANDS
declare -A global_subcommands=(
)

add_global_subcommand() {
  local service="$1"
  local command="$2"

  if [[ " ${!global_subcommands[@]} " =~ " $command " ]]; then
    echo "[CORE] Unable to register global subcommand: following exist:"
    echo "       $command for service ${global_subcommands[$command]}"
    echo "       $command for service $service"
    exit 1
  fi
  global_subcommands[$command]="$service"
}

source $CORE_DIR/borg.sh
source $CORE_DIR/docker.sh
source $CORE_DIR/cmd_git.sh

# FUNCTIONS
source $CORE_DIR/func_env.sh
source $CORE_DIR/func_help.sh
source $CORE_DIR/func_exec.sh
source $CORE_DIR/func_generate.sh

# MAIN
main() {
  local command="$1"

  load_env "$1"

  # check if ":" is in the command
  if [[ $command == *":"* ]]; then
    # split the string by ":"
    IFS=":" read -ra command_parts <<<"$command"

    for command_part in "${command_parts[@]}"; do
      main $command_part
    done
    return 0
  fi

  if [[ ! " ${!commands[@]} " =~ " $command " ]]; then

    # check if command is a global sub-command
    if [[ " ${!global_subcommands[@]} " =~ " $command " ]]; then
      local service="${global_subcommands[$command]}"
      shift
      cmd_$service $command "$@"
      return 0
    fi

    cmd_help
    if ! [[ -z "$command" ]]; then
      echo
      echo "Unknown command: $command"
    fi
    exit 1
  fi

  shift
  cmd_$command "$@"
}
