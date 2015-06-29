#!/usr/bin/env bash

# mark the ruby package as hold, so that apt won't update it.  if it updates,
# it gets pushed to ruby 1.9, which we don't want.
apt-mark hold ruby

apt-get update
apt-get install -y rubygems python-twisted git libxml2-dev libxslt-dev curl libcurl4-openssl-dev python-software-properties mongodb vim

# Install bundler, rake, and specific versions of some of the gems that are
# either known to work with ShC or work-around specific problems in the
# vagrant provisioning.
gem install bundler
gem install rake
gem install i18n --version 0.6.11
gem install rails --version 3.2.19

# Add the user and group needed for nginx
id -u deploy &>/dev/null || useradd -r -G sudo deploy

# install passenger and nginx to go with it
gem install passenger
passenger-install-nginx-module --auto --auto-download

# add an rc.d script for nginx
cd
curl -s -O https://raw.githubusercontent.com/jnstq/rails-nginx-passenger-ubuntu/master/nginx/nginx
mv nginx /etc/init.d/nginx
chown root:root /etc/init.d/nginx
chmod 755 /etc/init.d/nginx
update-rc.d nginx defaults

# reset the nginx config to something that works for us.  i would have
# liked to do this with augeas, but I couldn't get it to scan nginx.conf
# for some reason.  even with a newer version of augeas it still never
# loaded it.
cat <<EOF > /opt/nginx/conf/nginx.conf
user deploy;
worker_processes  1;

error_log /opt/nginx/logs/error.log;
pid       /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    passenger_root /var/lib/gems/1.8/gems/passenger-5.0.11;
    passenger_ruby /usr/bin/ruby1.8;
    passenger_max_pool_size 6;
    passenger_buffer_response on;
    passenger_min_instances 1;
    passenger_max_instances_per_app 0;
    passenger_pool_idle_time 300;
    passenger_max_requests 0;

    include       mime.types;
    default_type  application/octet-stream;

    sendfile       on;
    tcp_nopush     on;
    tcp_nodelay    on;

    keepalive_timeout  65;

    gzip  on;
    gzip_http_version 1.0;
    gzip_comp_level 2;
    gzip_proxied any;
    gzip_vary off;
    gzip_types text/plain text/html text/css text/xml text/javascript application/json application/x-javascript application/xml application/xml+rss;
    gzip_min_length 1000;
    gzip_disable "MSIE [1-6]\.";
    gzip_static off;

    server {
        listen       80;
        server_name  localhost;

        location / {
            root   html;
            index  index.html index.htm;
        }

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

    server {
        listen 81;
        server_name ubuntu-12;
        access_log /opt/nginx/logs/shadowcraft.access.log;

        location / {
            root /var/www/shadowcraft-ui/public;
            passenger_enabled on;
            rails_env development;
        }
    }
}

include /opt/include/sites-enabled/*;
EOF
