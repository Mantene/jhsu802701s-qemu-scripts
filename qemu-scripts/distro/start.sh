#!/bin/bash

# NOTE: set -o pipefail is needed to ensure that any error or failure causes the whole pipeline to fail.
# Without this specification, the CI status will provide a false sense of security by showing builds
# as succeeding in spite of errors or failures.
set -eo pipefail

source bin/set-parameters

ISO_READY='false'

echo "ISO file: $ISO_FILE"
echo "Image file: $IMAGE_FILE"
echo 'Parameters are stored in the parameters directory.'

mkdir -p 'parameters'
mkdir -p 'iso'
mkdir -p 'image'

# PROCEDURE
# 1A. If a virtual machine is available, skip ahead to boot up
#     without an ISO file.
# 1B. If the ISO file is present, skip ahead to verify it.
# 1C. Verify the ISO file.  If this pans out, skip ahead to boot up
#     with it.

# 2A. Check for the URL to the ISO file to download.
# 2B. Check for the stored checksum value of the ISO file.
# 2C. Check for the stored checksum method (sha256 or sha512).

# 3A. Ask the user for the path to the ISO file to download.
# 3B. Ask the user for the checksum value of the ISO file to download.
# 3C. Ask the user for the checksum method (sha256 or sha512).
# 3D. Store these parameters.

# 4A. Download the ISO file.
# 4B. Verify the ISO file.  If this step fails, go back to 4A until
#     the file has been verified OR after too many attempts fail to
#     pan out.
# 4C. If the file fails too many times, return to Step 3A.

# 5A. If there is a pre-existing virtual machine, boot it up without
#     the ISO file in the virtual CD drive.
# 5B. If there is no pre-existing virtual machine, boot it up with
#     the ISO file in the virtual CD drive.

function ask_for_checksum_method () {
  echo 'There are several different checksum methods for verifying'
  echo 'ISO files.  sha256sum and sha512sum are recommended.  sha1sum'
  echo 'and md5sum are discouraged for security reasons but may be'
  echo 'the only option available for certain Linux distros.'
  echo ''
  echo 'Enter the checksum method you wish to use to verify the ISO'
  read -p 'file: ' CHECKSUM_METHOD
  echo "Your selected checksum method: $CHECKSUM_METHOD"
  echo "$CHECKSUM_METHOD" > "$CHECKSUM_METHOD_FILE"
}

function ask_for_checksum_value () {
  echo 'Enter the checksum value you wish to use for verifying the ISO'
  read -p 'file: ' CHECKSUM_VALUE
  echo "The checksum value you entered was: $CHECKSUM_VALUE"
  echo "$CHECKSUM_VALUE" > "$CHECKSUM_VALUE_FILE"
}

function verify_iso_file () {
  echo '-----------------------------'
  echo 'BEGIN: verifying the ISO file'
  echo '-----------------------------'
  if [ ! -e "$CHECKSUM_METHOD_FILE" ]; then
    echo "$CHECKSUM_METHOD_FILE does not exist"
    ask_for_checksum_method
  fi
  if [ ! -e "$CHECKSUM_VALUE_FILE" ]; then
    echo "$CHECKSUM_VALUE_FILE does not exist"
    ask_for_checksum_value
  fi
  CHECKSUM_METHOD=`cat "$CHECKSUM_METHOD_FILE"`
  CHECKSUM_VALUE_EXPECTED=`cat "$CHECKSUM_VALUE_FILE"`
  CHECKSUM_VALUE_ACTUAL_LONG=`"$CHECKSUM_METHOD" "$ISO_FILE"`
  CHECKSUM_VALUE_ACTUAL_1="${CHECKSUM_VALUE_ACTUAL_LONG/$ISO_FILE/}"
  CHECKSUM_VALUE_ACTUAL=${CHECKSUM_VALUE_ACTUAL_1/'  '}
  echo "Checksum method: $CHECKSUM_METHOD"
  echo "Checksum value (expected): $CHECKSUM_VALUE_EXPECTED"
  echo "Checksum value (actual):   $CHECKSUM_VALUE_ACTUAL"
  if [ "$CHECKSUM_VALUE_EXPECTED" = "$CHECKSUM_VALUE_ACTUAL" ]
  then
    ISO_READY='true'
    echo 'The input ISO file is ready.'
  else
    echo '---------------------------------------'
    echo 'ERROR: The input ISO file is not ready.'
    echo 'Make sure that you have the correct ISO file, the correct'
    echo 'checksum method, and the correct checksum value.'
    echo '---------------------------------------'
    exit 1
  fi
  echo '--------------------------------'
  echo 'FINISHED: verifying the ISO file'
  echo '--------------------------------'
}

function download_file () {
  URL_TO_DOWNLOAD="$1"
  PATH_TO_FILE="$2"
  wait
  echo '---------------------------------------------------------'
  echo "BEGIN: downloading from $URL_TO_DOWNLOAD to $PATH_TO_FILE"
  echo '---------------------------------------------------------'
  set +e
  wget "$URL_TO_DOWNLOAD" --progress=dot -e dotbytes=10M -O "$PATH_TO_FILE"
  set -e
  wait
  echo '------------------------------------------------------------'
  echo "FINISHED: downloading from $URL_TO_DOWNLOAD to $PATH_TO_FILE"
  echo '------------------------------------------------------------'
}

function ask_user_for_iso_url () {
  echo ''
  echo 'Open the web browser and go to the web page containing the'
  echo 'ISO file (*.iso) to download.'
  echo ''
  echo 'Copy and paste the URL shown in the address bar.'
  read -p '' ISO_URL_1
  echo ''
  echo "$ISO_URL" > 'parameters/iso_url.txt'
  echo 'Enter the name of the ISO file to download (*.iso):'
  read -p '' ISO_URL_2
  echo ''
  ISO_URL_FULL="${ISO_URL_1}${ISO_URL_2}"
  echo "$ISO_URL_1" > "$ISO_URL_1_FILENAME"
  echo "$ISO_URL_2" > "$ISO_URL_2_FILENAME"
  echo "$ISO_URL_FULL" > "$ISO_URL_FULL_FILENAME"
}

# Check to determine if it is necessary to download the ISO file.
# Download the ISO file if it is necessary.
until [ "$ISO_READY" == 'true' ]
do
  if [ -f "$IMAGE_FILE" ]; then
    # The virtual machine is already in place.
    ISO_READY='true'
    echo ''
    echo 'The disk image file'
    echo "$IMAGE_FILE"
    echo 'already exists and does not need to be created at this time.'
    echo ''
  else
    # The virtual machine does not already exist.
    if [ -f "$ISO_FILE" ]; then
      # ISO file is present but not yet verified
      echo ''
      echo 'The ISO file'
      echo "$ISO_FILE"
      echo 'already exists and does not need to be downloaded at'
      echo 'this time.'
      echo ''
      verify_iso_file
    else
      # ISO file is not present
      ask_for_checksum_method
      ask_for_checksum_value
      ask_user_for_iso_url
      download_file "$ISO_URL_FULL" "$ISO_FILE"
    fi
  fi
done

# Check to determine if the virtual machine exists.
# Create a new virtual machine if necessary.
if [ -f "$IMAGE_FILE" ]; then
  # The virtual machine is already in place.
  echo ''
  echo 'The disk image file'
  echo "$IMAGE_FILE"
  echo 'already exists and does not need to be created at this time.'
  echo ''
else
  echo "To set the size to 20 GB, enter '20G'."
  echo "Enter the desired size of the new virtual machine:"
  read -p '' IMAGE_SIZE
  echo '------------------------------------------------'
  echo "qemu-img create -f qcow2 $IMAGE_FILE $IMAGE_SIZE"
  qemu-img create -f qcow2 "$IMAGE_FILE" "$IMAGE_SIZE"
  wait
fi

# Start a new virtual machine

# Get the host system resolution
# Source: https://askubuntu.com/questions/584688/how-can-i-get-the-monitor-resolution-using-the-command-line
X_HOST=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
Y_HOST=$(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)
echo "Host system resolution: $X_HOST X $Y_HOST"

# Set the guest system resolution
X_GUEST=$((X_HOST * 3 / 4))
Y_GUEST=$((Y_HOST * 3 / 4))
echo "Guest system resolution: $X_GUEST X $Y_GUEST"

NUM_CORES=''
if [ ! -e "$NUM_CORES_FILE" ]; then
  NUM_CORES_TOTAL=$(nproc --all)
  echo "Number of cores in your host machine's CPU: $NUM_CORES_TOTAL"
  echo 'Enter the number of cores you wish to use in your'
  read -p 'virtual machine: ' NUM_CORES
  echo "$NUM_CORES" > "$NUM_CORES_FILE"
else
  NUM_CORES=`cat "$NUM_CORES_FILE"`
fi
echo "Number of cores to use: $NUM_CORES"

AMT_MEMORY=''
if [ ! -e "$AMT_MEMORY_FILE" ]; then
  AMT_MEMORY_TOTAL=$(free -m | grep Mem: | awk '{print $2}')
  echo "Amount of memory in your host machine (MB): $AMT_MEMORY_TOTAL"
  echo 'Enter the amount of memory you wish to dedicate to your'
  read -p 'virtual machine (MB): ' AMT_MEMORY
  echo "$AMT_MEMORY" > "$AMT_MEMORY_FILE"
else
  AMT_MEMORY=`cat "$AMT_MEMORY_FILE"`
fi
echo "Amount of memory to use: $AMT_MEMORY"

qemu-system-x86_64 \
    -enable-kvm \
    -m "$AMT_MEMORY" \
    -smp "$NUM_CORES" \
    -nic user,model=virtio \
    -drive file="$IMAGE_FILE",media=disk,if=virtio \
    -display sdl -vga none -device virtio-vga,xres=$X_GUEST,yres=$Y_GUEST \
    -cdrom "$ISO_FILE"
