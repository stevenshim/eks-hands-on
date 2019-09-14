#!/bin/bash
set -e
MYIP=$(dig +short myip.opendns.com @resolver1.opendns.com)

# Return json string manually.
echo "{\"myip\": \"$MYIP\"}"

# If you have installed 'jq' you can use jq command instead of echo manually.
#jq -n --arg myip "$MYIP" '{"myip":$myip}'