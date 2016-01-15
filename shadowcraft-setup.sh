#!/usr/bin/env bash

source /usr/local/rvm/scripts/rvm

# Make a directory for web stuff and clone the shadowcraft UI into it.
mkdir -p /var/www
cd /var/www
git clone https://github.com/cheald/shadowcraft-ui
cd shadowcraft-ui
git checkout 7.0

# Post-clone setup for the UI
gem install bundler
bundle install
RAILS_ENV=development bundle exec rake assets:precompile

# Get the web user out of the nginx configuration and chown the whole directory
# to that user/group
WEB_USER=`awk '/user/ {print $2}' /etc/nginx/nginx.conf`
WEB_USER=`echo ${WEB_USER} | awk -F\; '{print $1}'`
chown -R $WEB_USER:$WEB_USER /var/www/shadowcraft-ui

cp /var/www/shadowcraft-ui/backend/shadowcraft-engine.conf /etc/init

service shadowcraft-engine restart

# Now that we have the actual site loaded, restart nginx to get it to regenerate
# some of the static files.
service nginx restart

# Clone and install the shadowcraft engine.  We're using Fiery's engine now
# since it's the most up-to-date one.
cd /usr/local
git clone http://github.com/Fierydemise/ShadowCraft-Engine.git
cd ShadowCraft-Engine
python setup.py install
