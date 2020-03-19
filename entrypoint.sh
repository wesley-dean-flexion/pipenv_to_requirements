#!/bin/sh

output_filename="/tmp/requirements.txt"
input_filename="/tmp/Pipfile"
input_lock_filename="/tmp/Pipfile.lock"

quiet=""
freeze=""
output="--output $output_filename"
lockfile_provided="false"

while getopts "odfql" option; do
  case $option in
    o ) output="--output $output_filename" ;;
    d ) output="--dev-output $output_filename " ;;
    f ) freeze="--freeze" ;;
    q ) quiet="--quiet" ;;
    l ) lockfile_provided="true" ;;
  esac
done

shift $((OPTIND - 1))

cd $(dirname "$input_filename")

if [ "$lockfile_provided" = "true" ] ; then
  cat > "$input_lock_filename"
else
  cat > "$input_filename"
  pipenv --bare lock > /dev/null 2>&1
fi

pipenv_to_requirements $quiet $freeze $output

cat $output_filename
