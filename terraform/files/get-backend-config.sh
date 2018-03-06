#! /bin/bash
set -euxo pipefail

jq '{bucket: .backend.config.bucket, key: .backend.config.key, region: .backend.config.region}' $1