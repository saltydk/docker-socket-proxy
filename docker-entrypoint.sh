#!/bin/sh
set -e
set -x

# Normalize the input for ENABLE_IPV6 to lowercase
ENABLE_IPV6_LOWER=$(echo "$ENABLE_IPV6" | tr '[:upper:]' '[:lower:]')

# Check for different representations of 'true' and set BIND_CONFIG
case "$ENABLE_IPV6_LOWER" in
    1|true|yes)
        BIND_CONFIG="[::]:2375 v4v6"
        ;;
    *)
        BIND_CONFIG=":2375"
        ;;
esac

# Process the HAProxy configuration template
envsubst < /usr/local/etc/haproxy/haproxy.cfg.template > /usr/local/etc/haproxy/haproxy.cfg

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
    shift # "haproxy"
    # if the user wants "haproxy", let's add a couple useful flags
    #   -W  -- "master-worker mode" (similar to the old "haproxy-systemd-wrapper"; allows for reload via "SIGUSR2")
    #   -db -- disables background mode
    set -- haproxy -W -db "$@"
fi

exec "$@"
