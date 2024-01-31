#!/bin/sh
set -e

# Normalize the input for DISABLE_IPV6 to lowercase
DISABLE_IPV6_LOWER=$(echo "$DISABLE_IPV6" | tr '[:upper:]' '[:lower:]')

# Check for different representations of 'true' and set BIND_CONFIG
case "$DISABLE_IPV6_LOWER" in
    1|true|yes)
        BIND_CONFIG=":2375"
        echo "IPv6 Disabled"
        ;;
    *)
        BIND_CONFIG="[::]:2375 v4v6"
        echo "IPv6 Enabled"
        ;;
esac

# Process the HAProxy configuration template using sed
sed "s/\${BIND_CONFIG}/$BIND_CONFIG/g" /usr/local/etc/haproxy/haproxy.cfg.template > /usr/local/etc/haproxy/haproxy.cfg

# Command-line argument handling
if [ "${1#-}" != "$1" ]; then
    set -- haproxy "$@"
fi

if [ "$#" -eq 0 ] || [ "$1" = 'haproxy' ]; then
    if [ "$1" = 'haproxy' ]; then
        shift
    fi
    set -- haproxy -W -db -f /usr/local/etc/haproxy/haproxy.cfg "$@"
fi

exec "$@"
