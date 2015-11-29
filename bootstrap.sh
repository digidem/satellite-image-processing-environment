#!/usr/bin/env bash

# exit if an error occurs
set -e

# Default swap size
SWAP_SIZE="3G"

export DEBIAN_FRONTEND=noninteractive

print_status() {
    echo -e "$1"
}

print_status "Creating ${SWAP_SIZE} swap"
# Create empty file for swap
fallocate -l $SWAP_SIZE /swapfile
# Only root can read and write to swap
chmod 600 /swapfile
# Make file into a swap file
mkswap /swapfile > /dev/null
# Turn on swap
swapon /swapfile
# Make the swap file permanent
cat <<EOT >> /etc/fstab
/swapfile   none    swap    sw    0   0
EOT
# 0-100 a value closer to 0 prefers memory over disk
sysctl vm.swappiness=10 > /dev/null
# Make swapiness setting permanent
cat <<EOT >> /etc/sysctl.conf
vm.swappiness=10
EOT

print_status "Updating core packages"
# Add ubuntugis/ubuntugis-unstable package repo for gdal
add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable > /dev/null 2>&1
# Update and upgrade
apt-get -y update > /dev/null
apt-get -y upgrade > /dev/null

print_status "Installing gdal & requirements"
apt-get -y install gdal-bin libgdal-dev python-pip python-dev python-numpy python-scipy \
  libatlas-base-dev gfortran libfreetype6-dev awscli git python-gdal > /dev/null 2>&1

print_status "Installing Node"
# Add nodesource package repo for up-to-date node
curl -sL https://deb.nodesource.com/setup | sudo bash - > /dev/null
# We need build-essential for some npm installs
apt-get -y install build-essential nodejs > /dev/null
# Remove any existing tools called node
rm -rf /usr/bin/node
# Node on Ubuntu defaults to nodejs, to avoid conflict, but we need a link from node
ln -s /usr/bin/nodejs /usr/bin/node

# We're not updating npm for now. Default version is 1.4.28
# print_status "Updating npm"
# npm update -g npm > /dev/null

print_status "Installing npm packages for tilelive"
npm install -g --loglevel error mbtiles tilejson tl tilelive tilelive-omnivore tilelive-http tilelive-s3 tilelive-file > /dev/null

print_status "Installing npm package mapbox-tile-copy"
npm install -g --loglevel error mapbox-tile-copy > /dev/null

print_status "Installing landsat-util & requirements"
# This github repo contains wheelhouse files to speed up install of landsat-util
git clone https://github.com/digidem/landsat-util-wheelhouse.git /tmp/wheelhouse > /dev/null 2>&1
pip install --use-wheel --no-index --find-links=/tmp/wheelhouse pillow > /dev/null 2>&1
pip install --use-wheel --no-index --find-links=/tmp/wheelhouse landsat-util > /dev/null 2>&1
# Cleanup our wheelhouse
rm -r /tmp/wheelhouse
