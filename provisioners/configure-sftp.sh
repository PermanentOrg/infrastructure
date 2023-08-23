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

echo $PERM_ENV  > /data/www/host.txt

echo "Add custom sources"
cp $TEMPLATES_PATH/usr/share/keyrings/*.asc /usr/share/keyrings/

# Set up the correct node source
export NODE_VERSION=18
envsubst \
  < $TEMPLATES_PATH/etc/apt/sources.list.d/nodesource.sources \
  > /etc/apt/sources.list.d/nodesource.sources

echo "Install packages"
apt -qq update
apt -qq install -y \
  curl \
  nginx \
  nginx-extras \
  nodejs \
  unzip \
  wget

# Make sure nodejs exists
if ! [[ -f /usr/bin/nodejs ]]
then
   # It does not exist, so create it
   update-alternatives --quiet --install /usr/bin/nodejs nodejs /usr/bin/node 50 --slave /usr/share/man/man1/nodejs.1.gz nodejs.1.gz /usr/share/man/man1/node.1.gz
fi

echo "Install AWS CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm awscliv2.zip
rm -fr aws

echo "Configure nginx"
sudo service nginx stop
unlink /etc/nginx/sites-enabled/default
unlink /etc/nginx/nginx.conf
cp $TEMPLATES_PATH/etc/nginx/sftp-nginx.conf /etc/nginx/nginx.conf
mkdir /etc/nginx/streams-available
mkdir /etc/nginx/streams-enabled
cp $TEMPLATES_PATH/etc/nginx/streams-available/sftp-service.conf /etc/nginx/streams-available/sftp-service.conf
ln -s /etc/nginx/streams-available/sftp-service.conf /etc/nginx/streams-enabled/sftp-service.conf
sudo service nginx start

echo "Configure SFTP Service"
cp $TEMPLATES_PATH/etc/systemd/system/sftp.service /etc/systemd/system/sftp.service
cp $TEMPLATES_PATH/etc/systemd/system/sftp-storage-cleanup.service /etc/systemd/system/sftp-storage-cleanup.service
cp $TEMPLATES_PATH/etc/systemd/system/sftp-storage-cleanup.timer /etc/systemd/system/sftp-storage-cleanup.timer
mkdir /etc/permanent/
envsubst < $TEMPLATES_PATH/etc/permanent/sftp-service.env > /etc/permanent/sftp-service.env
systemctl enable sftp.service
systemctl enable sftp-storage-cleanup.timer

# Set up generic deploy directories
mkdir /var/www/.aws
mkdir /var/www/.cache
envsubst < $TEMPLATES_PATH/var/www/.aws/credentials > /var/www/.aws/credentials
envsubst < $TEMPLATES_PATH/var/www/.aws/config > /var/www/.aws/config
chown -R www-data /var/www/

mkdir /data/tmp
chmod 774 /data/tmp
chown -R www-data /data/tmp
chgrp -R $APP_USER /data/tmp

# For the deployer user to download packages from S3
cp -R /var/www/.aws /home/$APP_USER/
chown -R $APP_USER /home/$APP_USER/.aws
chgrp -R $APP_USER /home/$APP_USER/.aws

rm -rf $TEMPLATES_PATH

echo "ALL DONE"
