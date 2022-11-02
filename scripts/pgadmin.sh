#!/bin/bash

if [ ! "$(docker ps -q -f name=pgadmin4)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=pgadmin4)" ]; then
        # container has exited
        docker rm pgadmin4
    fi
    # Container is not running
    docker run \
      -v ~/.pgadmin:/var/lib/pgadmin \
      -v ~/.ssh:/root/.ssh:ro \
      --name pgadmin4 \
      --network host \
      --restart always \
      --user root \
      --dns-opt='options single-request' \
      -e "PGADMIN_LISTEN_PORT=5050" \
      -e "PGADMIN_LISTEN_ADDRESS=0.0.0.0" \
      -e "PGADMIN_CONFIG_SERVER_MODE=False" \
      -e "PGADMIN_DEFAULT_EMAIL=***REMOVED***" \
      -e "PGADMIN_DEFAULT_PASSWORD=toto" \
      -e "MASTER_PASSWORD_REQUIRED=false" \
      -d \
      dpage/pgadmin4:6.15
    sleep 6
fi
/opt/google/chrome/chrome http://localhost:5050
