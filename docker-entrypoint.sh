#!/bin/sh
set -e
set -x

echo "Starting entrypoint script..."

# Normalize the input for ENABLE_IPV6 to lowercase
echo "Processing ENABLE_IPV6 environment variable..."
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
echo "BIND_CONFIG set to: $BIND_CONFIG"

# Process the HAProxy configuration template
echo "Generating HAProxy configuration..."
envsubst < /usr/local/etc/haproxy/haproxy.cfg.template > /usr/local/etc/haproxy/haproxy.cfg

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- haproxy "$@"
fi

# if no args or first arg is 'haproxy'
if [ "$#" -eq 0 ] || [ "$1" = 'haproxy' ]; then
    # if 'haproxy' is the first arg or no args, shift and prepend the default command
    if [ "$1" = 'haproxy' ]; then
        shift
    fi
    set -- haproxy -W -db -f /usr/local/etc/haproxy/haproxy.cfg "$@"
fi

echo "Executing command: $@"
exec "$@"
