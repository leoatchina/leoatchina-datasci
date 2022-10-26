#!/bin/bash
# File              : buid.sh
# Author            : leoatchina <leoatchina@outlook.com>
# Date              : 2022.10.26
# Last Modified Date: 2022.10.26
# Last Modified By  : leoatchina <leoatchina@outlook.com>



pwd=$PWD

tag=$(cat ./Dockerfile | grep ^FROM | head -n 1 | awk '{print $2}' | sed "s/://g")

docker build -t leoatchina/$tag . && cd $pwd/datasci && \
  sed -i "s@^FROM leoatchina/\(\w\|\.\)\+@FROM leoatchina/$tag@g" Dockerfile && \
  docker build -t leoatchina/datasci .
