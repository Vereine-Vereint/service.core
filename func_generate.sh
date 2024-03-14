
# generate(filename)
# Generate a file from a template
# templates are located in templates/ of the SERVICE_DIR
# generated files are located in the generated/ of the SERVICE_DIR
# template variables are in the form of ${VAR}

generate() {
  local filename="$1"
  local template="$SERVICE_DIR/templates/$filename"
  local generated="$SERVICE_DIR/generated/$filename"

  if [[ -f $template ]]; then
    echo "Generating $filename"
    local path=$(dirname $generated)
    mkdir -p $path
    envsubst < $template > $generated
  else
    echo "Template $filename not found"
    exit 1
  fi
}
