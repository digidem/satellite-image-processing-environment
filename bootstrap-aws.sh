#!/usr/bin/env bash

# exit if an error occurs
set -e

# The Ubuntu Trusty Tahr image mounts the additional SSD volume
# at `/mnt`. We create a folder /mnt/data and `chown ubuntu`, and
# create a landsat folder within that for output of the `landsat-utl`
mkdir -p /mnt/data/landsat
chown -R ubuntu /mnt/data
sudo -u ubuntu ln -s /mnt/data/landsat /home/ubuntu/landsat
