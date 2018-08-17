#!/bin/bash

# To use this to setup the environment in your current shell:
#   source set-env.sh
# or
#   . set-env.sh

[ -f environment.conf ] && $(cat environment.conf | ( while read E; do if [[ $E =~ ^[A-Z0-9_]+=.+$ ]]; then echo "export $E"; fi; done ))

