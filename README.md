# grafana-s3-backup

A script which backups up the Grafana `sqlite3` DB to S3.

All the tool does is copy the file locally to `/opt/grafana/backups` with a timestamp, and then copies it to the S3 bucket given.

## Requirements

- [awscli](https://aws.amazon.com/cli/)


### awscli

The script makes use of [awscli](https://aws.amazon.com/cli/) for copying the `grafana.db` backup to S3.

#### Installation

To install `awscli`, you will need `Python` and it's package manager `Pip`. Then you can run:

```
pip install awscli
```

#### Auth

For authentication to gain access to the S3 bucket, you can faciliate this via:
- [IAM roles](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
- [Credntials file](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html)
- [Environment Variables](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html)


## Usage

```
$ ./grafana_backup.sh -h
Usage: ./grafana_backup.sh [-flag <argument>]:
    -h 		 help
    -s 		 Specify S3 bucket to use (REQUIRED)
    -d	     Specify Grafana DB directory location (Default: /var/lib/grafana)
    -b       Specify location for backups to be done locally before going to S3 (Default: /opt/grafana/backups)
```

The only required flag is the `S3_BUCKET`, just ensure the IAM user/role has write access to that bucket.


### Recovery

Currently this is a manual step, however it isn't difficult.

The file will be copied with a timestamp e.g. `grafana.db-290620171712`, the format is `grafana.db-DayMonthYearHourMinute`.

Once you have figure out which one you wish to recover from you, just need to download and rename the file back to `grafana.db` and put it in the location your config requires. Finally, restart Grafana and you should be good to go.
