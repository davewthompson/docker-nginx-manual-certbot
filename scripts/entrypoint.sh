#!/bin/bash

# When we get killed, kill all our children
trap "exit" INT TERM
trap "kill 0" EXIT

# Start up nginx, save PID so we can reload config
nginx -g "daemon off;" &
export NGINX_PID=$!

# Lastly, run startup scripts
for f in /scripts/startup/*.sh; do
    if [ -x "$f" ]; then
        echo "Running startup script $f"
        $f
    fi
done
echo "Done with startup"

# Sleep and run certbox renew, rather than faffing around with trying to work out
# when our certificates expire...
while [ true ]; do
    echo "Run certbot renew"
    certbot renew --debug

    # Sleep for 1 day
    sleep 1d &
    SLEEP_PID=$!

    # Wait on sleep so that when we get ctrl-c'ed it kills everything due to our trap
    wait "$SLEEP_PID"
done

