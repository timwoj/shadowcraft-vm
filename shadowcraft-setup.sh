#!/usr/bin/env bash

source /usr/local/rvm/scripts/rvm

# Make a directory for web stuff and clone the shadowcraft UI into it.
mkdir -p /var/www
cd /var/www
git clone https://github.com/cheald/shadowcraft-ui
cd shadowcraft-ui

# Post-clone setup for the UI
gem install bundler
bundle install

# Get the web user out of the nginx configuration and chown the whole directory
# to that user/group
WEB_USER=`awk '/user/ {print $2}' /etc/nginx/nginx.conf`
WEB_USER=`echo ${WEB_USER} | awk -F\; '{print $1}'`
chown -R $WEB_USER:$WEB_USER /var/www/shadowcraft-ui

cp /var/www/shadowcraft-ui/backend/shadowcraft-engine.conf /etc/init
cp /var/www/shadowcraft-ui/backend/shadowcraft-engine-all.conf /etc/init

sed -i 's/NUM_WORKERS=4/NUM_WORKERS=1/' /etc/init/shadowcraft-engine-all.conf
sed -i 's|/home/web/roguesim/|/var/www/shadowcraft-ui/|g' /etc/init/shadowcraft-engine.conf

# Clone and install the shadowcraft engine into the proper place.
cd /var/www/shadowcraft-ui/backend
mkdir log tmp

cd vendor
git clone http://github.com/Fierydemise/ShadowCraft-Engine.git engine-7.0
ln -s engine-7.0 engine
cd engine-7.0
git checkout legion

service shadowcraft-engine-all start

# Now that we have the actual site loaded, restart nginx to get it to regenerate
# some of the static files.
service nginx restart

