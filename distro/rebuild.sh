#!/bin/bash

# NOTE: set -o pipefail is needed to ensure that any error or failure causes the whole pipeline to fail.
# Without this specification, the CI status will provide a false sense of security by showing builds
# as succeeding in spite of errors or failures.
set -eo pipefail

source bin/set-parameters

echo '--------'
echo 'REBUILD:'
echo 'Starting a new disk image with new specs'
echo '----------------------------------------'

rm -f image
rm -f parameters

bash start.sh
