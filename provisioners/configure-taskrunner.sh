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
# Add mysql source
cp $TEMPLATES_PATH/etc/apt/sources.list.d/mysql.sources /etc/apt/sources.list.d/

# Add New Relic
curl -s https://download.newrelic.com/548C16BF.gpg | apt-key add -
cp $TEMPLATES_PATH/etc/apt/sources.list.d/newrelic.sources /etc/apt/sources.list.d/

apt-get -qq update
echo "Install mysql"
apt-get -qq install -y mysql-client
echo "Install conversion tools"
apt-get -qq install -y libreoffice ffmpeg mediainfo libde265-dev libheif-dev libimage-exiftool-perl
apt-get -qq install -y imagemagick wkhtmltopdf
# Only install apache2 to create www-data user, which daemons run as
apt-get -qq install -y apache2 php7.3 php-mysql php-memcache php-curl php-cli php-imagick php-gd php-xml php-mbstring php-zip php-igbinary php-msgpack
echo "Install New Relic"
apt-get install -y newrelic-php5

service apache2 stop
update-rc.d apache2 disable

echo "Configure ImageMagick"
cp $TEMPLATES_PATH/etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml

mkdir /var/www/.aws
mkdir /var/www/.cache
envsubst < $TEMPLATES_PATH/var/www/.aws/credentials > /var/www/.aws/credentials
envsubst < $TEMPLATES_PATH/var/www/.aws/config > /var/www/.aws/config
chown -R www-data /var/www/

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
