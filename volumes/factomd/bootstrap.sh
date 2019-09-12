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

if [[ -f "${BASH_SOURCE%/*}/bootstrap.zip" ]]; then
  read -p "The bootstrap.zip file already exists, do you want to re-download it? y/N  " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f bootstrap.zip
    wget https://factom-public-files.s3.us-east-2.amazonaws.com/bootstrap.zip
  fi
else
  wget https://factom-public-files.s3.us-east-2.amazonaws.com/bootstrap.zip
fi

mkdir -p "${BASH_SOURCE%/*}/main-database/ldb/MAIN/"
unzip bootstrap.zip -d "${BASH_SOURCE%/*}/main-database/ldb/MAIN/"

rm -f bootstrap.zip

