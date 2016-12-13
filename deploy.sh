#!/bin/bash

set -e

if [[ "x${TRAVIS_PULL_REQUEST}" != "xfalse" ]]; then
    echo "This is a pull request. skipping deploy ..."
    exit 0
fi

source config.sh

PN=blogc-lambda-deps
P="${PN}-${PV}"

FILES=( "${P}.tar.xz" )

do_curl() {
    curl \
        --silent \
        --ftp-create-dirs \
        --upload-file "${1}" \
        --user "${FTP_USER}:${FTP_PASSWORD}" \
        "ftp://${FTP_HOST}/public_html/${PN}/${P}/${1}"
}

echo " * Found files:"
for f in "${FILES[@]}"; do
    echo "   ${f}"
done
echo

for f in "${FILES[@]}"; do
    echo " * Processing file: ${f}:"

    echo -n "   Generating SHA512 checksum ... "
    sha512sum "${f}" > "${f}.sha512"
    echo "done"

    echo -n "   Uploading file ... "
    do_curl "${f}"
    echo "done"

    echo -n "   Uploading SHA512 checksum ... "
    do_curl "${f}.sha512"
    echo "done"

    echo
done
