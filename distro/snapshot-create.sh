#!/bin/bash

# NOTE: set -o pipefail is needed to ensure that any error or failure causes the whole pipeline to fail.
# Without this specification, the CI status will provide a false sense of security by showing builds
# as succeeding in spite of errors or failures.
set -eo pipefail

source bin/set-parameters

echo "Image file: $IMAGE_FILE"

echo "Enter the name of the new snapshot you wish to create:"
read -p '' SNAPSHOT_NAME

echo '-------------------------'
echo 'Creating the new snapshot'
qemu-img snapshot -c "$SNAPSHOT_NAME" "$IMAGE_FILE"
echo ''
echo '---------------------------'
qemu-img snapshot -l "$IMAGE_FILE"
