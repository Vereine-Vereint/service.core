# DOCKER COMMANDS
declare -A docker_commands=(
  [logs]=":Show logs of $SERVICE_NAME"
  [status]=":Show status of $SERVICE_NAME"
  [restart]=":Restart existing containers for $SERVICE_NAME"
  [down]=":Stop and remove $SERVICE_NAME"
  [up]=":Apply Docker Compose and start $SERVICE_NAME" 
  [stop]=":Stop existing containers for $SERVICE_NAME"
  [start]=":Start existing containers for $SERVICE_NAME"  
)

# DOCKER SUB COMMAND
commands+=([docker]=":Manage Docker operations")
cmd_docker() {
  local command="$1"

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
  docker compose -p $SERVICE_NAME logs -f
}

docker_status() {
  docker compose -p $SERVICE_NAME ps
}

docker_restart() {
  exec_attachment configure
  exec_attachment preRestart
  docker compose -p $SERVICE_NAME restart
  exec_attachment postRestart
}

docker_down() {
  exec_attachment preStop
  docker compose -p $SERVICE_NAME down
  exec_attachment postStop
}

docker_up() {
  exec_attachment configure
  exec_attachment preStart
  docker compose -p $SERVICE_NAME up -d
  exec_attachment postStart
}

docker_start() {
  exec_attachment configure
  exec_attachment preStart
  docker compose -p $SERVICE_NAME start
  exec_attachment postStart
}

docker_stop() {
  exec_attachment preStop
  docker compose -p $SERVICE_NAME stop
  exec_attachment postStop
}