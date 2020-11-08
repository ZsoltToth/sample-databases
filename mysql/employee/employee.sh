#!/usr/bin/env bash

CONTAINER_NAME=employee
ROOT_PASSWORD=secret
MYSQL_HOME=/home/mysql

SQL_DUMP_DIR=sql_dump
SQL_DUMP_URL=(
    "https://raw.githubusercontent.com/datacharmer/test_db/master/employees.sql"
    "https://raw.githubusercontent.com/datacharmer/test_db/master/load_departments.dump"
    "https://raw.githubusercontent.com/datacharmer/test_db/master/load_dept_emp.dump"
    "https://raw.githubusercontent.com/datacharmer/test_db/master/load_dept_manager.dump"
    "https://raw.githubusercontent.com/datacharmer/test_db/master/load_employees.dump"
    "https://raw.githubusercontent.com/datacharmer/test_db/master/load_salaries1.dump"
    "https://raw.githubusercontent.com/datacharmer/test_db/master/load_salaries2.dump"
    "https://raw.githubusercontent.com/datacharmer/test_db/master/load_salaries3.dump"
    "https://raw.githubusercontent.com/datacharmer/test_db/master/load_titles.dump"
    "https://raw.githubusercontent.com/datacharmer/test_db/master/show_elapsed.sql"
)


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
    docker exec -it $CONTAINER_NAME mysql -u root -p$ROOT_PASSWORD
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
        for url in ${SQL_DUMP_URL[@]}
        do
            curl $url -o $SQL_DUMP_DIR/$( echo $url | rev | cut -f1 -d/ | rev)
        done
    fi

    docker run \
     --detach \
     --name $CONTAINER_NAME \
     --publish 3306:3306 \
     --volume $(pwd)/$SQL_DUMP_DIR:$MYSQL_HOME \
     --env MYSQL_ROOT_PASSWORD=$ROOT_PASSWORD \
     mysql:8

    sleep 10s
    # TODO: Wait until MySQL started in the container or number of connection refused.
    # try=0
    # until [[ $(docker exec $CONTAINER_NAME mysql -u root -p$ROOT_PASSWORD -e ";") ]];
    # do
    #     printf "Connection Refused #%d time\n" $try
    #     try=$(expr $try + 1)
    #     sleep 1s
    # done
    docker exec --workdir $MYSQL_HOME $CONTAINER_NAME  sh -c "mysql -u root -p$ROOT_PASSWORD < employees.sql 2>/dev/null"

    exit 0
fi

