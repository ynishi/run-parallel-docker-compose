#!/bin/bash

declare -A RUNNAMES 
for i in $(seq 1 3); do
  RUNNAMES[$(docker-compose run -d ok)]=1
done

while [ ${#RUNNAMES[@]} -gt 0 ]; do
  for NAME in ${!RUNNAMES[@]}; do
    if ! docker-compose ps | grep $NAME ; then
      echo $NAME ended
      RET=$(docker inspect $NAME --format='{{.State.ExitCode}}')
      if [ "$RET" -ne 0 ]; then
        echo restarted
        RUNNAMES[$(docker-compose run -d ok)]=1 
      fi
      unset -v RUNNAMES[$NAME]
    fi
  done
  sleep 1
done
