#!/usr/bin/env bash

mkdir -p /var/www
cd /var/www
git clone http://github.com/cheald/shadowcraft-ui
cd shadowcraft-ui
gem install bundler
bundle install --deployment
chown -R deploy:deploy /var/www/shadowcraft-ui

cd /etc/nginx/sites-enabled
cat <<EOF >> shadowcraft
server {
  listen 81;
  server_name ubuntu-12;
  access_log /var/log/nginx/shadowcraft.access.log;
 
  location / {
    root /var/www/shadowcraft-ui/public;
    passenger_enabled on;
  }
}
EOF

cd /usr/local
git clone http://github.com/dazer/ShadowCraft-Engine.git
cd ShadowCraft-Engine
python setup.py install

cd /etc/nginx/conf.d
sed -i 's|^passenger_ruby .*|passenger_ruby /usr/local/rvm/rubies/ruby-1.8.7-p374/bin/ruby;|' /etc/nginx/conf.d/passenger
sed -i 's|^passenger_root .*|passenger_root /usr/local/rvm/gems/ruby-1.8.7-p374/gems/passenger-3.0.18;|' /etc/nginx/conf.d/passenger
