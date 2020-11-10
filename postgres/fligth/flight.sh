#!/usr/bin/env bash

CONTAINER_NAME=flight
POSTGRES_USER=root
POSTGRES_PASSWORD=secret
POSTGRES_HOME_DIR=/home/postgres
JDBC_PORT=5432

SQL_DUMP_DIR=sql_dump
SQL_ZIP_URL="https://edu.postgrespro.com/demo-small-en.zip"
ZIP_FILE=$(echo $SQL_ZIP_URL | rev | cut -f1 -d/ | rev)

if [[ $# -ne 1 ]]
then
    printf "employee.sh start|stop|cli|bash\n"
    exit 1
fi

if [ $1 == "bash" ]
then
    docker exec -it $CONTAINER_NAME bash
    exit 0
fi

if [ $1 == "cli" ]
then
    FLIGTH_DB_NAME=demo
    docker exec -it --env PGPASSWORD=$POSTGRES_PASSWORD $CONTAINER_NAME psql -U $POSTGRES_USER $FLIGTH_DB_NAME 
    exit 0
fi


if [ $1 == "stop" ]
then
    docker stop $CONTAINER_NAME
    docker container rm $CONTAINER_NAME
    exit 0
fi

if [ $1 == "start" ]
then
    if [ ! -d $SQL_DUMP_DIR ]
    then        
        mkdir $SQL_DUMP_DIR
        curl $SQL_ZIP_URL -o $SQL_DUMP_DIR/$ZIP_FILE
        unzip $SQL_DUMP_DIR/$ZIP_FILE -d $SQL_DUMP_DIR
    fi

    docker run \
     --detach \
     --name $CONTAINER_NAME \
     --publish $JDBC_PORT:$JDBC_PORT \
     --volume $(pwd)/$SQL_DUMP_DIR:$POSTGRES_HOME_DIR \
     --env POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
     --env POSTGRES_USER=$POSTGRES_USER \
    postgres:13

    sleep 10s
    # TODO: Wait until MySQL started in the container or number of connection refused.
    # try=0
    # until [[ $(docker exec $CONTAINER_NAME mysql -u root -p$ROOT_PASSWORD -e ";") ]];
    # do
    #     printf "Connection Refused #%d time\n" $try
    #     try=$(expr $try + 1)
    #     sleep 1s
    # done
    docker exec \
        --workdir $POSTGRES_HOME_DIR  \
        --env PGPASSWORD=$POSTGRES_PASSWORD \
        $CONTAINER_NAME \
        sh -c "psql -U $POSTGRES_USER  < demo-small-en-20170815.sql # 2>/dev/null"

    exit 0
fi

