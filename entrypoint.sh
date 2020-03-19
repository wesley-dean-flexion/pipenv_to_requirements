#!/bin/sh

quiet=""
freeze=""

output_filename="/tmp/requirements.txt"
input_filename="/tmp/Pipfile"

output="--output $output_filename"

while getopts "odfq" option; do
  case $option in
    o ) output="--output $output_filename" ;;
    d ) output="--dev-output $output_filename " ;;
    f ) freeze="--freeze" ;;
    q ) quiet="--quiet" ;;
  esac
done

shift $((OPTIND - 1))

cd $(dirname "$input_filename")

cat > "$input_filename"

pipenv --bare lock > /dev/null 2>&1

pipenv_to_requirements $quiet $freeze $output

cat $output_filename

