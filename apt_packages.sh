#!/usr/bin/env bash

# The vagrant box used pre-7.0 had a swapfile pre-configured. The one we
# use now doesn't, so generate one to keep things from out of memory during
# installation (namely passenger)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab

# install passenger and nginx to go with it
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https ca-certificates

# Add Passenger APT repository
sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'

# Update everything and install some of the dependent packages we'll need for other things
apt-get update
apt-get install -y python-twisted git curl python-software-properties mongodb vim build-essential libgmp3-dev libcurl4-openssl-dev nodejs
# Install rvm and a specific version of ruby
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.3
source /usr/local/rvm/scripts/rvm
rvm --default use ruby-2.2.3
gem install bundler

# Add the user and group needed for nginx
id -u deploy &>/dev/null || useradd -r -G sudo deploy

# Install Passenger & Nginx
apt-get install -y nginx-extras passenger

cat <<EOF > /etc/nginx/conf.d/passenger.conf
passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
passenger_ruby /usr/local/rvm/gems/ruby-2.2.3/wrappers/ruby;
passenger_max_pool_size 6;
passenger_buffer_response on;
passenger_min_instances 1;
passenger_max_instances_per_app 0;
passenger_pool_idle_time 300;
passenger_max_requests 0;
passenger_default_user www-data;
passenger_default_group www-data;

# To enable this, disable the other gzip settings in /etc/nginx/nginx.conf and
# uncomment everything below
#gzip on;
#gzip_http_version 1.0;
#gzip_comp_level 2;
#gzip_proxied any;
#gzip_vary off;
#gzip_types text/plain text/html text/css text/xml text/javascript application/json application/x-javascript application/xml application/xml+rss;
#gzip_min_length 1000;
#gzip_disable "MSIE [1-6]\.";
#gzip_static off;
EOF

cat <<EOF > /etc/nginx/sites-enabled/shadowcraft
server {
    listen 81;
    server_name shadowcraft;
    access_log /var/log/nginx/shadowcraft.access.log;

    location / {
        root /var/www/shadowcraft-ui/public;
        passenger_enabled on;
        rails_env development;
    }
}
EOF
