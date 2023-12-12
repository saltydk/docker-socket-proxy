#!/bin/sh
set -e
set -x # Debug mode: Print each command to stderr before executing it

echo "Starting entrypoint script..."

# Normalize the input for ENABLE_IPV6 to lowercase
echo "Processing ENABLE_IPV6 environment variable..."
ENABLE_IPV6_LOWER=$(echo "$ENABLE_IPV6" | tr '[:upper:]' '[:lower:]')
echo "ENABLE_IPV6_LOWER set to: $ENABLE_IPV6_LOWER"

# Check for different representations of 'true' and set BIND_CONFIG
case "$ENABLE_IPV6_LOWER" in
    1|true|yes)
        BIND_CONFIG="[::]:2375 v4v6"
        ;;
    *)
        BIND_CONFIG="0.0.0.0:2375"
        ;;
esac
echo "BIND_CONFIG set to: $BIND_CONFIG"

# Process the HAProxy configuration template
echo "Generating HAProxy configuration..."
envsubst < /usr/local/etc/haproxy/haproxy.cfg.template > /usr/local/etc/haproxy/haproxy.cfg || {
    echo "Error processing HAProxy configuration template."
    exit 1
}

# Check for command line arguments
echo "Processing command line arguments..."
if [ "${1#-}" != "$1" ]; then
    set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
    shift # remove "haproxy"
    set -- haproxy -W -db "$@"
fi

echo "Executing command: $@"
exec "$@"
