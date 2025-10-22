#!bin/bash

# Carmaker install script for Ubuntu 24.04

# NOTE: ROS2 Jazzy installation should already be done.

echo "Checking for Carmaker installation files..."
if [ ! -f "./CD-CarMakerOffice-linux-14.0.zip" ]; then
    echo "Carmaker Office 14.0."
    echo "Install it manually or using this UoL sharepoint link: https://leeds365-my.sharepoint.com/:u:/r/personal/sc23pg_leeds_ac_uk/Documents/Formula%20Student%20Racing/CD-CarMakerOffice-linux-14.0.zip?csf=1&web=1&e=11QKfG"
    exit 1
fi

echo "Unzipping Carmaker installation files..."
unzip ./CD-CarMakerOffice-linux-14.0.zip -d ./CD

export DEBIAN_FRONTEND=noninteractive
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections
apt-get install -y --reinstall ttf-mscorefonts-installer
dpkg-reconfigure -f noninteractive ttf-mscorefonts-installer

cd CD 
chmod +x ipg-install
echo "Running Carmaker installer..."
./ipg-install -batch -ipghome /opt/ipg || echo "Install warning: Check logs for license/package issues"


