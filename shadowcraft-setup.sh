#!/usr/bin/env bash

# Make a directory for web stuff and clone the shadowcraft UI into it.  Switch to the
# 6.0 branch of the UI as well since we're using the 6.0 version of the engine.
mkdir -p /var/www
cd /var/www
git clone http://github.com/cheald/shadowcraft-ui
cd shadowcraft-ui

# Post-clone setup for the UI
gem install bundler
bundle install
bundle install --deployment
chown -R deploy:deploy /var/www/shadowcraft-ui

# Add a site configuration for the UI site.  This hosts the site on port 81 on the VM, which
# should be mapped to port 8080 on the host machine.
cd /etc/nginx/sites-enabled
cat <<EOF > shadowcraft
server {
  listen 81;
  server_name ubuntu-12;
  access_log /var/log/nginx/shadowcraft.access.log;
 
  location / {
    root /var/www/shadowcraft-ui/public;
    passenger_enabled on;
    rails_env development;
  }
}
EOF

# Update the nginx config to point at the right versions of ruby and passenger
cd /etc/nginx/conf.d
sed -i 's|^passenger_ruby .*|passenger_ruby /usr/bin/ruby1.8;|' /etc/nginx/conf.d/passenger.conf
sed -i 's|^passenger_root .*|passenger_root /var/lib/gems/1.8/gems/passenger-3.0.18/;|' /etc/nginx/conf.d/passenger.conf

# Since everything was just updated in the nginx config, restart it.
service nginx restart

# Clone and install the shadowcraft engine
cd /usr/local
git clone http://github.com/dazer/ShadowCraft-Engine.git
cd ShadowCraft-Engine
python setup.py install

