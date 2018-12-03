#!/usr/bin/env bash

AWS_CONFIG_FILE="~/.aws/config"
DATAFILE=~/path/to/credentials/file

read -r USER PASSWORD < "$DATAFILE"

OUTPUT="/path/to/backup/directory"

databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" == "database_name" ]] ; then
	echo "Dumping database: $db"
	mysqldump --force --opt --user=$USER --password=$PASSWORD --databases $db > $OUTPUT/`date +%Y%m%d`.$db.sql
	gzip --force $OUTPUT/`date +%Y%m%d`.$db.sql
	/usr/bin/aws s3 cp /path/to/backup/directory s3://aws-bucket-name --recursive
	rm -rf /path/to/backup/directory/*.gz
    fi
done
