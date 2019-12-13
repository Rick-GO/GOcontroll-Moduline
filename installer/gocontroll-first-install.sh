#!/bin/bash

YELLOW='\033[33m'
NORMAL='\033[0m'


#call to this script:
#bash <(curl -sL https://github.com/Rick-GO/GOcontroll-Moduline-III/blob/master/installer/gocontroll-first-install)

# before system update start, update repositories
echo -e "${YELLOW} Update repositories before we do a system update ${NORMAL}"
apt-get update

# Go to root folder
cd 


if [ -d GOcontroll ]
then
echo -e "${YELLOW} Delete existing GOcontroll folder ${NORMAL}"
	rm -r GOcontroll
fi

# Create Folder
echo -e "${YELLOW} Create new GOcontroll folder ${NORMAL}"
mkdir GOcontroll

# Jump to folder
cd GOcontroll
ls

if ! [ -x "$(command -v git)" ]; then
echo -e "${YELLOW} Git is not yet installed so let's install first ${NORMAL}"
apt-get -y install git 
fi

# provide some user information:
echo -e "${YELLOW} Download files for GOcontroll Moduline III ${NORMAL}"

git clone https://github.com/Rick-GO/GOcontroll-Moduline-III.git

echo -e "${YELLOW}Update system ${NORMAL}"
apt-get update

echo -e "${YELLOW}Install hostapd ${NORMAL}"
apt-get -y install hostapd

echo -e "${YELLOW}Install dnsmasq ${NORMAL}"
echo -e "${YELLOW}delete config file if present ${NORMAL}"
rm /etc/dnsmasq.conf

apt-get -y install dnsmasq

echo -e "${YELLOW}Install libqmi tools ${NORMAL}"
apt-get -y install libqmi-utils

echo -e "${YELLOW}Install udhcpc ${NORMAL}"
apt-get -y install udhcpc

apt-get -y install curl

cd ~

curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh

bash nodesource_setup.sh

apt-get -y install nodejs

apt-get -y install build-essential

npm cache clean -f

npm install -g n

n stable

npm install -g --unsafe-perm node-red

echo -e "${YELLOW}Start Node RED to generate root folder ${NORMAL}"
timeout 20 node-red

npm install -g node-red-admin

wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/nodered.service -O /lib/systemd/system/nodered.service

wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/node-red-start -O /usr/bin/node-red-start

wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/node-red-stop -O /usr/bin/node-red-stop

chmod +x /usr/bin/node-red-st*

systemctl daemon-reload

echo -e "${YELLOW}Copy specific files to Platform ${NORMAL}"
cp -avr /root/GOcontroll/GOcontroll-Moduline-III/lib /
cp -avr /root/GOcontroll/GOcontroll-Moduline-III/nodered.service /lib/systemd/system
cp -avr /root/GOcontroll/GOcontroll-Moduline-III/interfaces /etc/network
cp -avr /root/GOcontroll/GOcontroll-Moduline-III/hostapd.conf /etc/hostapd
cp -avr /root/GOcontroll/GOcontroll-Moduline-III/hostapd /etc/default
cp -avr /root/GOcontroll/GOcontroll-Moduline-III/dnsmasq.conf /etc
cp -avr /root/GOcontroll/GOcontroll-Moduline-III/settings.js /root/.node-red
cp -avr /root/GOcontroll/GOcontroll-Moduline-III/node-red-contrib-canbus/ /usr
cp -avr /root/GOcontroll/GOcontroll-Moduline-III/node-red-gocontroll/ /usr
cp -avr /root/GOcontroll/GOcontroll-Moduline-III/qmi-network-raw /usr/local/bin


chmod 777 /usr/local/bin/qmi-network-raw

echo -e "${YELLOW}Activate modules for wifi ${NORMAL}"
depmod

echo -e "${YELLOW}Activate Services for wifi ${NORMAL}"
service hostapd start
service dnsmasq start

echo -e "${YELLOW}Jump node Node RED folder on root ${NORMAL}"
cd ~/.node-red

echo -e "${YELLOW}Install local node packages ${NORMAL}"

npm install /usr/node-red-gocontroll

echo -e "${YELLOW}Install extra webpackages ${NORMAL}"
npm install node-red-dashboard
npm install node-red-contrib-boolean-logic
npm install node-red-contrib-dsm

echo -e "${YELLOW}Start Node-RED service ${NORMAL}"
systemctl enable nodered.service 

echo -e "${YELLOW}Reboot ${NORMAL}"
reboot