#!/bin/bash
source /.env
source /_VARIABLES

apt update

cd $(pwd)/setup.d

for file in $(ls *.sh); do
  bash $file $1
done
