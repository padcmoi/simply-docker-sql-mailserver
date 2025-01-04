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

    if [ ! $signingTable -eq 0 ]; then
        echo "#__DOMAIN__$1" >>$SIGNING_TABLE
        echo "*@$1      default._domainkey.$1" >>$SIGNING_TABLE
        echo "*@*.$1    default._domainkey.$1" >>$SIGNING_TABLE
        echo "" >>$SIGNING_TABLE
    else
        echo "Error, the domain $1 already exists in signing.table"
    fi

    if [ ! $keyTable -eq 0 ]; then
        echo "#__DOMAIN__$1" >>$KEY_TABLE
        echo "default._domainkey.$1     $1:default:$KEYS_PATH$1/default.private" >>$KEY_TABLE
        echo "" >>$KEY_TABLE
    else
        echo "Error, the domain $1 already exists in key.table"
    fi

    if [ ! $trustedHosts -eq 0 ]; then
        echo "#__DOMAIN__$1" >>$TRUSTED_HOSTS
        echo ".$1" >>$TRUSTED_HOSTS
        echo "" >>$TRUSTED_HOSTS
    else
        echo "Error, the domain $1 already exists in trusted.hosts"
    fi

    check $1

    if [ ! -d "${KEYS_PATH}${1}" ] &&
        [ $signingTable -eq 0 ] &&
        [ $keyTable -eq 0 ] &&
        [ $trustedHosts -eq 0 ]; then

        mkdir -p "${KEYS_PATH}${1}"

        opendkim-genkey -b 2048 -d $1 -D "${KEYS_PATH}${1}" -s default -v

        chown opendkim:opendkim "${KEYS_PATH}${1}/default.private"
        chmod 600 "${KEYS_PATH}${1}/default.private"
        chmod 777 "${KEYS_PATH}${1}/default.txt"

        cat "${KEYS_PATH}${1}/default.txt"
    else
        echo "Error, domain key dkim $1 could not be created"
    fi

else
    echo "Please give me an arg"
fi
