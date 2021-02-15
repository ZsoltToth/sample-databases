#!/usr/bin/env bash

REDIS_CONTAINER_NAME=redis

docker exec -it $REDIS_CONTAINER_NAME redis-cli
