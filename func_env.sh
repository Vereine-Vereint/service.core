# loads the .env file in the main directory

commands+=([set-env]="<env_name>:Sets the name of the .env file to be loaded and checks it")
cmd_set-env() {
  local var=$1
  if [ ${#1} -gt 4 ]; then
    last_four="${1: -4}"
    if [ "$last_four" != ".env" ]; then
      var="$1.env"
    fi
  fi
  # save to core/selected.env
  echo "ENV=$var" >core/selected.env

  load_env
}

load_env() {
  if [ "$1" == "set-env" ]; then
    return
  fi

  set -o allexport
  if [ -f "core/selected.env" ]; then
    ENV_FILE=$(cat core/selected.env | sed 's/ENV=//g')
  else
    ENV_FILE="$SERVICE_NAME.env"
  fi
  set +o allexport
  echo "[ENVIRONMENT] $ENV_FILE"
  echo

  # check if .env file exists
  if [ ! -f "$SERVICES_DIR/$ENV_FILE" ]; then
    echo "$ENV_FILE not found"

    # ask if new .env file should be created
    read -p "[ENVIRONMENT] Do you want to create a new $ENV_FILE file? (y/N) " create_env

    # if yes, create empty .env file else exit
    case "$create_env" in
    [yY][eE][sS] | [yY])
      echo "Created empty $ENV_FILE file"
      ;;
    *)
      echo "exiting"
      exit 1
      ;;
    esac

    sed -E 's/=(.*)$/= #\1/' .env.example >"$SERVICES_DIR/$ENV_FILE"
    echo
    echo "Please fill the $ENV_FILE file"
    exit 1
  fi

  # import .env file
  set -o allexport
  source $SERVICES_DIR/$ENV_FILE
  set +o allexport

  # check if all variables are set
  # (load all variable names from .env.example and check if they are set)
  all_vars_set=1
  local env_vars=$(cat .env.example | sed 's/#.*//g' | sed 's/=.*//g' | xargs)
  for env_var in $env_vars; do
    if [ -z "${!env_var}" ]; then
      echo "Variable $env_var is not set"
      all_vars_set=0
    fi
  done

  if [ $all_vars_set -eq 0 ]; then
    echo
    echo "Please fill the $ENV_FILE file"
    exit 1
  fi

}
