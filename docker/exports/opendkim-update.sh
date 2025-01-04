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

    if [ ! -d "${KEYS_PATH}${1}" ]; then
        echo "Warn, the folder containing the key $1 doesnt exist"
    elif
        [ ! $signingTable -eq 0 ] || [ ! $keyTable -eq 0 ] || [ ! $trustedHosts -eq 0 ]
    then
        echo "Error, one or more domains are missing in the configuration"
    else
        opendkim-genkey -b 2048 -d $1 -D "${KEYS_PATH}${1}" -s mail -v

        chown opendkim:opendkim "${KEYS_PATH}${1}/mail.private"
        chmod 600 "${KEYS_PATH}${1}/mail.private"
        chmod 777 "${KEYS_PATH}${1}/mail.txt"

        cat "${KEYS_PATH}${1}/mail.txt"
    fi

else
    echo "Please give me an arg"
fi
