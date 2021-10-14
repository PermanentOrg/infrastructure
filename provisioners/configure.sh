#!/usr/bin/env bash
echo "Running configuration script"
export DEBIAN_FRONTEND=noninteractive

echo "US/Central" | sudo tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

if [[ -z "$AWS_REGION" || -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_ACCESS_SECRET" ]]
    then
	echo "ERROR! Missing critical environment variable: AWS_REGION, AWS_ACCESS_KEY_ID, AWS_ACCESS_SECRET!"
    exit 1
fi

echo "Install essential software pacakges"
apt-get -qq update
apt-get -qq install -y curl htop wget build-essential zip software-properties-common gnupg awscli

echo $PERM_ENV  > /data/www/host.txt

# Preseed responses to New Relic installation questions
echo newrelic-php5 newrelic-php5/application-name string $NEW_RELIC_APPLICATION_NAME | debconf-set-selections
echo newrelic-php5 newrelic-php5/license-key string $NEW_RELIC_LICENSE_KEY | debconf-set-selections

echo "Add custom sources"
# Add mysql key
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 5072E1F5
# Add New Relic key
curl -s https://download.newrelic.com/548C16BF.gpg | apt-key add -
# Add node key
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
# Add custom sources
cp $TEMPLATES_PATH/etc/apt/sources.list.d/* /etc/apt/sources.list.d/

apt-get -qq update
echo "Install mysql"
apt-get -qq install -y mysql-client
echo "Install nodejs"
apt-get -qq install -y nodejs
echo "Install conversion tools"
apt-get -qq install -y libreoffice ffmpeg mediainfo libde265-dev libheif-dev libimage-exiftool-perl
apt-get -qq install -y imagemagick wkhtmltopdf
apt-get -qq install -y apache2 php7.3 libapache2-mod-php php-mysql php-memcache php-curl php-cli php-imagick php-gd php-xml php-mbstring php-zip php-igbinary php-msgpack
echo "Install New Relic"
apt-get install -y newrelic-php5
echo "Configure ImageMagick"
cp $TEMPLATES_PATH/etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml

# Make sure nodejs exists
if ! [[ -f /usr/bin/nodejs ]]
then
   # It does not exist, so create it
   update-alternatives --quiet --install /usr/bin/nodejs nodejs /usr/bin/node 50 --slave /usr/share/man/man1/nodejs.1.gz nodejs.1.gz /usr/share/man/man1/node.1.gz
fi

echo "Configure apache"

# This is the Apache DocumentRoot, and where the aws php sdk will look for credentials
mkdir /var/www/.aws
mkdir /var/www/.cache
envsubst < $TEMPLATES_PATH/var/www/.aws/credentials > /var/www/.aws/credentials
envsubst < $TEMPLATES_PATH/var/www/.aws/config > /var/www/.aws/config

# This is needed for our iOS app to open links to Permanent in the app
# https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html
mkdir /var/www/html/.well-known
envsubst \
  < $TEMPLATES_PATH/var/www/html/.well-known/apple-app-site-association \
  > /var/www/html/.well-known/apple-app-site-association

# Make www-data the owner of /var/www/ because writing to this dir is required for file conversions
chown -R www-data /var/www/

service apache2 stop
a2dissite 000-default
cp $TEMPLATES_PATH/etc/apache2/apache2.conf /etc/apache2/apache2.conf
envsubst < $TEMPLATES_PATH/etc/apache2/sites-enabled/$PERM_SUBDOMAIN.permanent.conf > /etc/apache2/sites-enabled/$PERM_SUBDOMAIN.permanent.conf
envsubst < $TEMPLATES_PATH/etc/apache2/sites-enabled/preload.permanent.conf > /etc/apache2/sites-enabled/preload.permanent.conf
a2enmod expires
a2enmod headers
a2enmod rewrite
a2enmod proxy
a2enconf security
a2enconf charset
a2enconf other-vhosts-access-log

echo "Configure Upload Service"
envsubst < $TEMPLATES_PATH/etc/systemd/system/upload.service > /etc/systemd/system/upload.service
systemctl enable upload.service

echo "Configure Notification Service"
cp $TEMPLATES_PATH/etc/systemd/system/notification.service /etc/systemd/system/notification.service
mkdir /etc/permanent/
envsubst < $TEMPLATES_PATH/etc/permanent/notification-service.env > /etc/permanent/notification-service.env

systemctl enable notification.service

echo "Install node global packages"
npm install npm --global
npm install -g gulp
npm install -g bower
npm install -g forever
npm install -g @angular/cli@7.3.6

mkdir /data/tmp
mkdir /data/tmp/uploader
chmod -R 774 /data/tmp
chown -R www-data /data/tmp
chgrp -R $APP_USER /data/tmp

# For the deployer user to download packages from S3
cp -R /var/www/.aws /home/$APP_USER/
chown -R $APP_USER /home/$APP_USER/.aws
chgrp -R $APP_USER /home/$APP_USER/.aws

# For cronjobs that run as root
cp -R /var/www/.aws /root/
chown -R root /root/.aws
chgrp -R root /root/.aws

rm -rf $TEMPLATES_PATH

echo "ALL DONE"
