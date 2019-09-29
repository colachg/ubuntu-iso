#!/bin/bash
docker run -it --rm --privileged \
-v ${PWD}/sources.list:/etc/apt/sources.list \
-v ${PWD}/scripts:/scripts \
-v ${PWD}/output:/output \
ubuntu:18.04 /bin/bash /scripts/setup.sh
