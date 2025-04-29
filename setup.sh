#!/bin/bash

# NOTE: set -o pipefail is needed to ensure that any error or failure causes the whole pipeline to fail.
# Without this specification, the CI status will provide a false sense of security by showing builds
# as succeeding in spite of errors or failures.
set -eo pipefail

echo 'Enter the nickname of the virtual machine you wish to create:'
read -p '' ABBREV_VM

bin/setup-distro-directory "$ABBREV_VM"
