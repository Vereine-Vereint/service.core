# loads the .env file in the main directory

commands+=(["set-env"]="<env_name>:Sets the name of the .env file to be loaded and checks it")
cmd_set-env() {
  # save to core/selected.env
  echo "ENV=$1.env" >core/selected.env

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
    
    exec_in_place "$SERVICES_DIR/$ENV_FILE"
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

# Function to execute commands in place
# Cuts all commands from a file and replaces them with the output of the command
# There are some limitations to this function:
# - The command must be enclosed in "#$(" and ")"
# - The command must not contain any special characters like /
# - The command must not contain any null bytes, they will be ignored and an error will be shown
# - The command must not contain any newlines, they will be replaced with spaces
exec_in_place() {
  local file="$1"

  # Save the current IFS value and set it to newline
  oldIFS=$IFS
  IFS=$'\n'

  # Find all instances of $(command) in the file
  commands=($(cat "$file" | grep -oP '\#\$\(\K[^)]+(?=\))' | awk '{print}' | tr '\0' '\n'))

  # Restore the IFS value
  IFS=$oldIFS

  # Iterate over the commands
  for cmd in "${commands[@]}"; do
    # Execute the command and capture the output
    result="$(eval "$cmd" 2>&1 | tr '\n' ' ' | sed 's/ *$//')"

    # the script still shows erros due to null bytes in the cmd
    # however it ignores the null bytes in the result and works fine

    # Escape special characters in the command to avoid issues with sed
    escaped_cmd=$(printf '%s\n' "$cmd" | sed -e 's/[\/&]/\\&/g')

    # Escape special characters in the result to avoid issues with sed
    escaped_result=$(printf '%s\n' "$result" | sed -e 's/[\/&]/\\&/g')

    # Print the sed command for testing purposes
    # echo sed -i "s/\$($escaped_cmd)/$escaped_result/g" "$file"

    # Replace the command with its output in the file
    sed -i "s/\#\$($escaped_cmd)/$escaped_result/g" "$file"
  done

}
