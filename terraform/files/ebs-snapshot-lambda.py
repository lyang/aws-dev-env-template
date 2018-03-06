import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timedelta, timezone
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)
ec2_client = boto3.client('ec2')
ec2_resource = boto3.resource('ec2')


def handle(event, context):
    snapshot(event["volume-id"], event["managed-by"])
    cleanup(event["ebs-snapshot-retention"], event["managed-by"])


def snapshot(volume_id, managed_by):
    try:
        result = ec2_client.create_snapshot(
            VolumeId=volume_id,
            Description='Created by Lambda function ebs-snapshot'
        )

        snapshot = ec2_resource.Snapshot(result['SnapshotId'])
        snapshot.create_tags(Tags=[{'Key': 'ManagedBy', 'Value': managed_by}, {'Key': 'Baseline', 'Value': "False"}])
        logger.info("Snapshot created for %s", volume_id)
    except ClientError as e:
        logger.error(e)


def cleanup(retention, managed_by):
    now = datetime.now(timezone.utc)
    try:
        result = ec2_client.describe_snapshots(
            OwnerIds=["self"],
            Filters=[{"Name": "tag:ManagedBy", "Values": [managed_by]}, {"Name": "tag:Baseline", "Values": ["False"]}]
        )
        for snapshot in result['Snapshots']:
            if (now - snapshot["StartTime"]) > timedelta(int(retention)):
                snapshot.delete()
            else:
                logger.info("Skipping snapshot %s", snapshot["SnapshotId"])
    except ClientError as e:
        logger.error(e)
