#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

. "${BASEDIR}/update.conf"

set -xe
set -o pipefail

cat -- "${BASEDIR}/Makejail.template" |\
    sed -E \
        -e "s/%%TAG1%%/${TAG1}/g" \
        -e "s/%%PHP2%%/${PHP2}/g" \
        -e "s/%%VERSION%%/${VERSION}/g" > "${BASEDIR}/../Makejail"

cat -- "${BASEDIR}/download-wordpress.makejail.template" |\
    sed -Ee "s/%%VERSION%%/${VERSION}/g" > "${BASEDIR}/../download-wordpress.makejail"

cat -- "${BASEDIR}/README.md.template" |\
    sed -E \
        -e "s/%%TAG1%%/${TAG1}/g" \
        -e "s/%%TAG2%%/${TAG2}/g" \
        -e "s/%%PHP1%%/${PHP1}/g" \
        -e "s/%%PHP2%%/${PHP2}/g" \
        -e "s/%%VERSION%%/${VERSION}/g" > "${BASEDIR}/../README.md"
