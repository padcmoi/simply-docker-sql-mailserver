#!/bin/bash

SIGNING_TABLE="/etc/opendkim/signing.table"
KEY_TABLE="/etc/opendkim/key.table"
TRUSTED_HOSTS="/etc/opendkim/trusted.hosts"
KEYS_PATH="/etc/opendkim/keys/"

check() {
    grep -E "#__DOMAIN__$1$" $SIGNING_TABLE >>/dev/null
    signingTable=$?

    grep -E "#__DOMAIN__$1$" $KEY_TABLE >>/dev/null
    keyTable=$?

    grep -E "#__DOMAIN__$1$" $TRUSTED_HOSTS >>/dev/null
    trustedHosts=$?
}

if [ $1 ]; then

    check $1

    if [ $signingTable -eq 0 ]; then
        sed -i "/#__DOMAIN__$1$/{N;N;N;d}" $SIGNING_TABLE
    else
        echo "Warn, the domain $1 doesnt exist in signing.table"
    fi

    if [ $keyTable -eq 0 ]; then
        sed -i "/#__DOMAIN__$1$/{N;N;d}" $KEY_TABLE
    else
        echo "Warn, the domain $1 doesnt exist in key.table"
    fi

    if [ $trustedHosts -eq 0 ]; then
        sed -i "/#__DOMAIN__$1$/{N;N;d}" $TRUSTED_HOSTS

    else
        echo "Warn, the domain $1 doesnt exist in trusted.hosts"
    fi

    if [ -d "${KEYS_PATH}${1}" ]; then
        rm -Rf "${KEYS_PATH}${1}"
    else
        echo "Warn, the folder containing the key $1 doesnt exist"
    fi

else
    echo "Please give me an arg"
fi
