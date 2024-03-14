
commands+=([logs]=":Show logs of $SERVICE_NAME")
cmd_logs() {
  docker compose -p $SERVICE_NAME logs -f
}

commands+=([status]=":Show status of $SERVICE_NAME")
cmd_status() {
  docker compose -p $SERVICE_NAME ps
}

commands+=([restart]=":Restart $SERVICE_NAME")
cmd_restart() {
  exec_attachment configure
  exec_attachment preRestart
  docker compose -p $SERVICE_NAME restart
  exec_attachment postRestart
}

commands+=([stop]=":Stop $SERVICE_NAME")
cmd_stop() {
  exec_attachment preStop
  docker compose -p $SERVICE_NAME down
  exec_attachment postStop
}

commands+=([start]=":Start $SERVICE_NAME")
cmd_start() {
  exec_attachment configure
  exec_attachment preStart
  docker compose -p $SERVICE_NAME up -d
  exec_attachment postStart
}
