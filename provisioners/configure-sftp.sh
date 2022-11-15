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
cp $TEMPLATES_PATH/etc/apt/sources.list.d/*.sources /etc/apt/sources.list.d/

echo "Install packages"
apt -qq update
apt -qq install -y \
  curl \
  wget \
  nginx \
	nginx-extras \
	unzip

echo "Install NodeJs"
# The way to pin to a specific version of node is to load directly
# See https://github.com/nodesource/distributions/issues/33#issuecomment-169345680
curl -o nodejs.deb https://deb.nodesource.com/node_16.x/pool/main/n/nodejs/nodejs_16.17.1-deb-1nodesource1_amd64.deb
apt -y install ./nodejs.deb
rm ./nodejs.deb

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
mkdir /etc/permanent/
envsubst < $TEMPLATES_PATH/etc/permanent/sftp-service.env > /etc/permanent/sftp-service.env
systemctl enable sftp.service

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
