
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

# executes generate for all files
# in the templates directory recursively
generate_all() {
    # find all files (-type f) in the templates directory
    # and strip the SERVICE_DIR/templates/ part
    local files=$(find $SERVICE_DIR/templates -type f | sed "s|$SERVICE_DIR/templates/||")

    # iterate over all files and generate them
    for fl in $files; do
        generate $fl
    done
}