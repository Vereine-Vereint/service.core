# DOCKER COMMANDS
declare -A docker_commands=(
  [logs]=":Show logs of $SERVICE_NAME"
  [status]=":Show status of $SERVICE_NAME"
  [restart]=":Restart existing containers for $SERVICE_NAME"
  [down]=":Stop and remove $SERVICE_NAME"
  [up]=":Apply Docker Compose and start $SERVICE_NAME"
  [stop]=":Stop existing containers for $SERVICE_NAME"
  [start]=":Start existing containers for $SERVICE_NAME"
  [pull]=":Pull images for $SERVICE_NAME"
  [build]=":Build images for $SERVICE_NAME"
  ["delete-volumes"]=":Delete volumes for $SERVICE_NAME"
)

# DOCKER GLOBAL SUB-COMMANDS
add_global_subcommand "docker" "down"
add_global_subcommand "docker" "up"
add_global_subcommand "docker" "delete-volumes"
add_global_subcommand "docker" "stop"
add_global_subcommand "docker" "start"
add_global_subcommand "docker" "pull"
add_global_subcommand "docker" "build"
add_global_subcommand "docker" "restart"
add_global_subcommand "docker" "logs"
add_global_subcommand "docker" "status"

# DOCKER SUB COMMAND
commands+=([docker]=":Manage Docker operations")
cmd_docker() {
  local command="$1"

  # check if ":" is in the command
  if [[ $command == *":"* ]]; then
    # split the string by ":"
    IFS=":" read -ra command_parts <<<"$command"

    for command_part in "${command_parts[@]}"; do
      cmd_docker $command_part
    done
    return 0
  fi

  if [[ ! " ${!docker_commands[@]} " =~ " $command " ]]; then
    print_help "docker " "docker_commands"
    if ! [[ -z "$command" ]]; then
      echo
      echo "Unknown command: docker $command"
    fi
    exit 1
  fi

  cd $SERVICE_DIR
  shift # remove first argument ("docker" command)
  docker_$command "$@"
}

# FUNCTIONS
docker_logs() {
  docker compose -p $SERVICE_NAME logs -f "$@"
}

docker_status() {
  docker compose -p $SERVICE_NAME ps "$@"
}

docker_restart() {
  exec_attachment configure
  generate_all
  docker compose -p $SERVICE_NAME restart "$@"
}

docker_down() {
  docker compose -p $SERVICE_NAME down --remove-orphans "$@"
}

docker_up() {
  exec_attachment setup
  exec_attachment configure
  generate_all
  docker compose -p $SERVICE_NAME up -d "$@"
}

docker_start() {
  exec_attachment configure
  generate_all
  docker compose -p $SERVICE_NAME start "$@"
}

docker_stop() {
  docker compose -p $SERVICE_NAME stop "$@"
}

docker_pull() {
  docker compose -p $SERVICE_NAME pull "$@"
}

docker_build() {
  docker compose -p $SERVICE_NAME build "$@"
}

docker_delete-volumes() {

  sudo rm -rf $SERVICE_DIR/volumes
}
