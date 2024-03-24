CORE_VERSION="v1.2"

CORE_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "[CORE] $CORE_VERSION ($(cd $CORE_DIR && git rev-parse --short HEAD))"

SERVICES_DIR=$(dirname $SERVICE_DIR)

# COMMANDS
declare -A commands=(
  [help]=":Show this help message"
)
cmd_help() {
  print_help "" "commands"
}
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

  if [[ ! " ${!commands[@]} " =~ " $command " ]]; then
    cmd_help
    if ! [[ -z "$command" ]]; then
      echo
      echo "Unknown command: $command"
    fi
    exit 1
  fi

  load_env "$1"

  shift
  cmd_$command "$@"
}
