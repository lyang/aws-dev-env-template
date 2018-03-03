#!/bin/bash

BASE_SNAPSHOT_ID=$1
TAG_VALUE=$2
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq .instanceId -r)
VOLUME_ID=$(aws ec2 describe-volumes --region $REGION --filter Name=attachment.instance-id,Values=$INSTANCE_ID,Name=snapshot-id,Values=$BASE_SNAPSHOT_ID | jq .Volumes[0].VolumeId -r)
SNAPSHOT_ID=$(aws ec2 create-snapshot --region $REGION --volume-id $VOLUME_ID --description "Created by script $0" | jq .SnapshotId -r)
aws ec2 create-tags --region $REGION --resource $SNAPSHOT_ID --tags Key=Name,Value=$TAG_VALUE Key=Seed,Value=False