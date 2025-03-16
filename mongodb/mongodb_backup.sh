#!/bin/bash

docker exec <mongodb-container-name> mongodump --db your_database_name \
    --username your_user --password your_password --authenticationDatabase admin \
    --out /backup