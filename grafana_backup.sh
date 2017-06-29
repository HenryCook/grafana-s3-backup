#!/usr/bin/env bash

set -e

DB_DIR="/var/lib/grafana"
BACKUP_DIR="/opt/grafana/backups"
BACKUP_FILE="grafana.db-$(date +%d%m%Y%H%M)"


usage() {

echo "Usage: ${0} [-flag <argument>]:
    -h 		   help
    -s 		   Specify S3 bucket to use (REQUIRED)
    -d	     Specify Grafana DB directory location (Default: /var/lib/grafana)
    -b       Specify location for backups to be done locally before going to S3 (Default: /opt/grafana/backups)"

exit 1

}

while getopts s:d:b:h opt; do
    case "${opt}" in
	s)
      S3_BUCKET=${OPTARG}
	    ;;
  d)
      DB_DIR=${OPTARG}
	    ;;
	b)
	    BACKUP_DIR=${OPTARG}
	    ;;
	h)
      usage
      ;;
  *)
      echo "Incorrect flag given"
      usage;
      exit 1
      ;;
    esac
done

shift $((OPTIND-1))

if [ -z $S3_BUCKET ]; then
    echo "Please specify which bucket you wish to use via the '-s' flag"
    usage
    exit 1
fi


if [ ! -d $BACKUP_DIR ]; then
    echo "The directory '$BACKUP_DIR' not present, creating now."
    mkdir -p $BACKUP_DIR
fi

DB="$DB_DIR/grafana.db"

cp $DB $BACKUP_DIR/$BACKUP_FILE

if [ -e $BACKUP_DIR/$BACKUP_FILE ]; then

    # Upload to AWS
    aws s3 cp $BACKUP_DIR/$BACKUP_FILE s3://$S3_BUCKET/grafana/$BACKUP_FILE

    # Test result of last command run
    if [ "$?" -ne "0" ]; then
        echo "Upload to AWS failed"
        exit 1
    fi

    # Exit with no error
    exit 0
fi

# Exit with error if we reach this point
echo "Backup file not created"


exit 0
