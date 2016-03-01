#!/bin/bash
set -e # exit with nonzero exit code if anything fails

# Upload artifacts to FTP server
find build -type f -exec curl -u ${FTP_USER}@${FTP_PASS} --ftp-create-dirs -T {} ftp://${FTP_HOST}/beta{} \;