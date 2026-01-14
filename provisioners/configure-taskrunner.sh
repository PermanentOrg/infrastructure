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

echo $PERM_ENV  > /data/www/host.txt

# Preseed responses to New Relic installation questions
echo newrelic-php5 newrelic-php5/application-name string $NEW_RELIC_APPLICATION_NAME | debconf-set-selections
echo newrelic-php5 newrelic-php5/license-key string $NEW_RELIC_LICENSE_KEY | debconf-set-selections

echo "Install curl"
apt update
apt install -y curl

echo "Add custom sources"
curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
dpkg -i /tmp/debsuryorg-archive-keyring.deb
cp $TEMPLATES_PATH/usr/share/keyrings/*.asc /usr/share/keyrings/
cp $TEMPLATES_PATH/usr/share/keyrings/*.gpg /usr/share/keyrings/
cp $TEMPLATES_PATH/etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/

# Set up the correct node source
export NODE_VERSION=24
export NODESOURCE_ARCHITECTURE=$(dpkg --print-architecture)
export NODESOURCE_SUITE="trixie"

envsubst \
  < $TEMPLATES_PATH/etc/apt/sources.list.d/nodesource.sources \
  > /etc/apt/sources.list.d/nodesource.sources

echo "Install packages"
apt-get -qq update
# Only install apache2 to create www-data user, which daemons run as
apt-get -qq install -y \
  apache2 \
  awscli \
  build-essential \
  ffmpeg \
  gnupg \
  htop \
  imagemagick \
  libde265-dev \
  libheif-dev \
  libimage-exiftool-perl \
  libreoffice \
  mediainfo \
  newrelic-php5 \
  php8.3-cli \
  php8.3-curl \
  php8.3-gd \
  php8.3-igbinary \
  php8.3-imagick \
  php8.3-mbstring \
  php8.3-memcache \
  php8.3-msgpack \
  php8.3-pgsql \
  php8.3-xml \
  php8.3-zip \
  php8.3 \
  postgresql-client \
  wget \
  zip \
  cron

# wkhtmltopdf was removed from Debian 13, install from archived release
curl -fsSL -o /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_amd64.deb
apt-get install -y /tmp/wkhtmltox.deb
rm /tmp/wkhtmltox.deb

service apache2 stop
update-rc.d apache2 disable

echo "Configure ImageMagick"
cp $TEMPLATES_PATH/etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml

mkdir /var/www/.aws
mkdir /var/www/.cache
envsubst \
  < $TEMPLATES_PATH/var/www/.aws/credentials \
  > /var/www/.aws/credentials
envsubst \
  < $TEMPLATES_PATH/var/www/.aws/config \
  > /var/www/.aws/config
chown -R www-data /var/www/
cp "${TEMPLATES_PATH}/etc/ca-certificates/rds-us-west-2-ca-bundle.pem" /etc/ca-certificates/rds-us-west-2-ca-bundle.pem

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
