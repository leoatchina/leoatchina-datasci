#!/bin/bash
# File              : push.sh
# Author            : leoatchina <leoatchina@outlook.com>
# Date              : 2022.11.07
# Last Modified Date: 2022.11.07
# Last Modified By  : leoatchina <leoatchina@outlook.com>


 for i in `docker images | grep leoatchina | head -n 2 | awk '{printf "%s:%s\n", $1,$2}' | sort -r`; do echo $i;docker push $i; done
