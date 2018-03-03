import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timedelta, timezone
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)
ec2_client = boto3.client('ec2')
ec2_resource = boto3.resource('ec2')


def handle(event, context):
    snapshot(event["volume-id"], event["ebs-snapshot-tag"])
    cleanup(event["ebs-snapshot-retention"], event["ebs-snapshot-tag"])


def snapshot(volume_id, ebs_snapshot_tag):
    try:
        result = ec2_client.create_snapshot(
            VolumeId=volume_id,
            Description='Created by Lambda function ebs-snapshot'
        )

        snapshot = ec2_resource.Snapshot(result['SnapshotId'])
        snapshot.create_tags(Tags=[{'Key': 'Name', 'Value': ebs_snapshot_tag}, {'Key': 'Seed', 'Value': "False"}])
        logger.info("Snapshot created for %s", volume_id)
    except ClientError as e:
        logger.error(e)


def cleanup(retention, ebs_snapshot_tag):
    now = datetime.now(timezone.utc)
    try:
        result = ec2_client.describe_snapshots(
            OwnerIds=["self"],
            Filters=[{"Name": "tag:Name", "Values": [ebs_snapshot_tag]}, {"Name": "tag:Seed", "Values": ["False"]}]
        )
        for snapshot in result['Snapshots']:
            if (now - snapshot["StartTime"]) > timedelta(int(retention)):
                snapshot.delete()
            else:
                logger.info("Skipping snapshot %s", snapshot["SnapshotId"])
    except ClientError as e:
        logger.error(e)
