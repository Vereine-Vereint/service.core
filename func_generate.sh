# generate(filename)
# Generate a file from a template
# templates are located in templates/ of the SERVICE_DIR
# generated files are located in the generated/ of the SERVICE_DIR
# template variables are in the form of ${VAR}

# $1: from/template/path.yml
# $2: to/path.yml

generate() {
  local template="$1"
  local generated="$2"

  if [[ ! -f $template ]]; then
    echo "Template file not found"
    exit 1
  fi

  if [[ -z $generated ]]; then
    echo "Generated path not provided"
    exit 1
  fi

  echo "Generating $generated"
  local path=$(dirname $generated)
  mkdir -p $path
  envsubst <$template >$generated
}
