#!/bin/sh

##
## defaults
##

# where to write (and then read) the Pipfile from STDIN
input_filename="/tmp/Pipfile"

# where to write (and then read) the Pipfile.lock from STDIN when using -l
input_lock_filename="/tmp/Pipfile.lock"

# where to write the output to be passed out via STDOUT
output_filename="/tmp/requirements.txt"

# quiet (no logs) flag for pipenv_to_requirements
quiet=""

# freeze versions flag for pipenv_to_requirements
freeze=""

# what to write and where
output="--output $output_filename"

# if "true", then a Pipfile.lock was passed via STDIN; when "false", Pipfile
lockfile_provided="false"

##
## Parse CLI arguments
##

while getopts "odfql" option; do
  case "$option" in
    o ) output="--output $output_filename" ;;
    d ) output="--dev-output $output_filename " ;;
    f ) freeze="--freeze" ;;
    q ) quiet="--quiet" ;;
    l ) lockfile_provided="true" ;;
    * ) echo "Invalid option: ${option}; quitting."; exit 1 ;;
  esac
done

# just in case we get strings (e.g., filenames) passed after any flags are
# parsed by getopts are caught and put into $1, $2, etc..
shift $((OPTIND - 1))

# make sure we're in the right directory
cd "$(dirname "$input_filename")" || exit 1

# if we get a Pipfile.lock, no need to run `pipenv lock` on it, so skip it
if [ "$lockfile_provided" = "true" ] ; then
  # write directly to Pipfile.lock
  cat > "$input_lock_filename"
else
  cat > "$input_filename"
  # parse Pipfile -> Pipfile.lock
  pipenv --bare lock > /dev/null 2>&1
fi

# convert the Pipfile.lock to requirements.txt (or requirements-dev.txt)
pipenv_to_requirements $quiet $freeze $output

# write the results to STDOUT
cat "$output_filename"
