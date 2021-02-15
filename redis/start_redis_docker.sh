#!/usr/bin/env bash

REDIS_CONTAINER_NAME=redis
REDIS_NETWORK=redis-network


docker run \
	--rm \
	--name $REDIS_CONTAINER_NAME \
       	redis
