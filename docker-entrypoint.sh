#!/bin/bash
set -e

echo "Executing $BASH_SOURCE"
for script in $(find / -maxdepth 1 -regex '/docker-entrypoint.+\.sh' | sort); do
        . $script $@
done

echo "Starting Command"
exec $@

