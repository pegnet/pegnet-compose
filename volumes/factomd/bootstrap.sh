#!/bin/bash

if [[ -d "${BASH_SOURCE%/*}/main-database/ldb/MAIN/factoid_level.db/" ]]; then
  read -p "The blockchain directory already exists, do you want to replace it? y/N  " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
  else
    rm -rf "${BASH_SOURCE%/*}/main-database/ldb/MAIN/factoid_level.db"
  fi
fi

apt-get install -y unzip wget
wget https://factom-public-files.s3.us-east-2.amazonaws.com/bootstrap.zip

mkdir -p "${BASH_SOURCE%/*}/main-database/ldb/MAIN/"
unzip bootstrap.zip -d "${BASH_SOURCE%/*}/main-database/ldb/MAIN/"

rm -f bootstrap.zip

