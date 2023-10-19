#!/bin/bash

#
# This is a wrapper around the existing send_command.sh and print_ircc_codes.sh
# which improves ergonomics a bit by allowing the user to run a command based on 
# the name of the command name.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Ensure jq is installed
if ! command -v jq &> /dev/null
then
    echo "j$(basename $0): jq could not be found. Please install jq." >&2
    exit 1
fi

# Check for BRAVIA_IP environment variable
if [[ -z "${BRAVIA_IP}" ]]; then
    echo "$(basename $0): BRAVIA_IP environment variable is not set." >&2
    echo "See https://github.com/breunigs/bravia-auth-and-remote#setup" >&2
    exit 1
fi


# Check for BRAVIA_PSK environment variable
if [[ -z "${BRAVIA_PSK}" ]]; then
    echo "$(basename $0): BRAVIA_PSK environment variable is not set." >&2
    echo "See https://github.com/breunigs/bravia-auth-and-remote#setup" >&2
    exit 1
fi


BRAVIA_JSON=$($DIR/print_ircc_codes.sh $BRAVIA_IP)

if [ "$#" -eq 0 ]; then
  echo "The following commands are available:"
  echo
  echo $BRAVIA_JSON | jq -r '.result[1][]["name"]' | column
  echo
  echo "Run a command with '$0 COMMAND'."

  exit
fi

declare -a not_found_names

# Check all names to ensure they exist
for name in "$@"; do
  VALUE=$(echo "$BRAVIA_JSON" | jq -r --arg name "$name" '.result[1][] | select(.name == $name).value')
  if [ "$VALUE" == "" ]; then
    not_found_names+=("$name")
  fi
done

if [ ${#not_found_names[@]} -ne 0 ]; then
  echo "The following commands are not available: ${not_found_names[*]}" >&2
  echo "To see all available commands, run $0 without any parameters." >&2
  exit 1
fi

# If all names exist, process each one
for name in "$@"; do
  VALUE=$(echo "$BRAVIA_JSON" | jq -r --arg name "$name" '.result[1][] | select(.name == $name).value')
  echo "  $DIR/send_command.sh $BRAVIA_PSK $BRAVIA_IP $VALUE"
  $DIR/send_command.sh $BRAVIA_IP $BRAVIA_PSK $VALUE
  # This delay is just a guess, may need to be adjusted
  sleep 0.2
done

