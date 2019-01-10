#!/usr/bin/env bash

AWS_CONFIG_FILE="~/.aws/config"
DATAFILE=~/path/to/credentials/file

read -r USER PASSWORD < "$DATAFILE"

OUTPUT="/path/to/backup/directory"

databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" == "db_name" ]] ; then
	echo "Dumping database: $db"
	mysqldump --force --opt --user=$USER --password=$PASSWORD --databases $db > $OUTPUT/`date +%Y%m%d`.$db.sql
	gzip --force $OUTPUT/`date +%Y%m%d`.$db.sql
	/usr/bin/aws s3 cp $OUTPUT s3://aws-bucket-name --recursive
	rm -rf $OUTPUT/*.gz
    fi
done
