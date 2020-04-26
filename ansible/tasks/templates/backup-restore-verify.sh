#!/bin/bash
echo "----- Clean up backups -----" &&
ls -rdt /var/lib/mongodb-backup/dump-* |
head -n -$MONGODB_BACKUP_KEEP |
xargs rm -rf &&
DIR=/var/lib/mongodb-backup/dump-`date +%F-%T` &&
echo "----- Start mongodump at $DIR -----" &&
mongodump -j 1 -u admin -p $MONGODB_ADMIN_PASSWORD --host $MONGODB_SERVICE_NAME --port $MONGODB_SERVICE_PORT --authenticationDatabase=admin --gzip --out=$DIR &&
echo &&
echo "----- Start mongorestore for db: $MONGODB_DATABASE -----" &&
mongorestore -u admin -p $MONGODB_ADMIN_PASSWORD --authenticationDatabase admin --gzip $DIR/$MONGODB_DATABASE -d $MONGODB_DATABASE &&
echo "----- Verify $MONGODB_DATABASE exists -----" &&
mongo admin -u admin -p $MONGODB_ADMIN_PASSWORD --eval='db.adminCommand( { listDatabases: 1, nameOnly: true, filter: { name: "rocketdb" } } )'