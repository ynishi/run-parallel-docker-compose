#!/bin/bash

declare -A RUNNAMES
for i in $(seq 1 3); do
  sleep 1
  RUNNED=$(docker-compose run -d ok)
  echo $RUNNED started
  docker logs -f -t $RUNNED &
  RUNNAMES[$RUNNED]=1
done

while [ ${#RUNNAMES[@]} -gt 0 ]; do
  for NAME in ${!RUNNAMES[@]}; do
    if ! docker ps | grep -q $NAME ; then
      echo $NAME ended
      RET=$(docker inspect $NAME --format='{{.State.ExitCode}}')
      if [ "$RET" -ne 0 ]; then
        RUNNED=$(docker-compose run -d ok)
        docker logs -f -t $RUNNED &
        RUNNAMES[$RUNNED]=1
        echo $NAME restarted as $RUNNED
      fi
      unset -v RUNNAMES[$NAME]
    fi
  done
  sleep 1
done
