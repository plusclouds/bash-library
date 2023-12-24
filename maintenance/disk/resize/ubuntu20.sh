#!/usr/bin/env bash
# @copyright This script is taken from the page https://superuser.com/questions/332252/how-to-create-and-format-a-partition-using-a-bash-script

# This script will extend the root partition. Do not use if the volume is built with LVM

# Assigning out default partition as /dev/xvda3 because we are using this partition in PlusClouds
VOL="${VARIABLE:-/dev/xvda}"

# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${VOL}
  d # delete the partition
  3 # selecting partition 3 for this
  n # new partition
  p # primary partition
  3 # partition number 3
    # enter to select minimum block
    # enret to select the maximum block
  w # write to partition table
  q # and we're done
EOF

resize2fs /dev/xvda3
