#!/usr/bin/env bash

apt-get update
apt-get install -y rubygems python-twisted

export DEBIAN_FRONTEND=noninteractive
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

gem install bundler
gem install rake
gem install rails --version 3.2.19
