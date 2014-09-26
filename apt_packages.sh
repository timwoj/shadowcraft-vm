#!/usr/bin/env bash

apt-get update
apt-get install -y rubygems python-twisted git libxml2-dev libxslt-dev

# mark the ruby package as hold, so that apt won't update it.  if it updates, it gets pushed to
# ruby 1.9, which we don't want.
apt-mark hold ruby

# this extra stuff here allows apt-get to upgrade all of the packages without needing user input.
# grub always wants to pop up a menu and cause problems.
export DEBIAN_FRONTEND=noninteractive
#apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# Insatll bundler, gem, and a specific version of rails that's known to work.
gem install bundler
gem install rake
gem install rails --version 3.2.19
