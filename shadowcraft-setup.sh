#!/usr/bin/env bash

# Make a directory for web stuff and clone the shadowcraft UI into it.
mkdir -p /var/www
cd /var/www
git clone https://github.com/cheald/shadowcraft-ui
cd shadowcraft-ui

# Post-clone setup for the UI
gem install bundler
bundle install
bundle install --deployment
chown -R deploy:deploy /var/www/shadowcraft-ui

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

