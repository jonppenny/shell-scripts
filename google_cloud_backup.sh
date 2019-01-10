#!/usr/bin/env bash

DATAFILE=~/path/to/credentials

read -r USER PASSWORD < "$DATAFILE"

OUTPUT="/path/to/backup/directory"

databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" == "db_name" ]] ; then
	echo "Dumping database: $db"
	mysqldump --force --opt --user=$USER --password=$PASSWORD --databases $db > $OUTPUT/`date +%Y%m%d%H%M%S`.$db.sql
	gzip --force $OUTPUT/`date +%Y%m%d%H%M%S`.$db.sql
	rm -rf $OUTPUT/*.sql
	gsutil rsync -r $OUTPUT gs://google-bucket-name
	rm -rf $OUTPUT/*.gz
    fi
done
