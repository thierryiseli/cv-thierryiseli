#!/bin/bash

upload_url=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}"  \
     -d "{\"tag_name\": \"${VERSION}\", \"name\":\"${RELEASE_NAME}}\",\"body\":\"${RELEASE_DESCRIPTION}\"}\"  \
     "https://api.github.com/repos/${REPOSITORY_NAME}/releases" | jq -r '.upload_url')

upload_url="${upload_url%\{*}"

echo "uploading asset to release to url : $upload_url"

curl -s -H "Authorization: token ${GITHUB_TOKEN}"  \
        -H "Content-Type: application/pdf" \
        --data-binary @${UPLOAD_FILE}  \
        "$upload_url\?name=${UPLOAD_FILE}\&label=${UPLOAD_FILE}"   