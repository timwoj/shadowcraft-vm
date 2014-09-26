shadowcraft-vm
==============

Vagrant configuration for running [Shadowcraft-UI](https://github.com/cheald/shadowcraft-ui) and [Shadowcraft-Engine](https://github.com/dazer/ShadowCraft-Engine).  See those projects for more information about what they do individually.

## Installation

1. Install Vagrant from http://vagrantup.com
2. Install Virtualbox from http://virtualbox.org
3. Clone this repo
4. Open a command line (cmd.exe, Terminal.app, xterm, etc) and enter the directory of the repo
5. Run the following commands to initialize the vagrant environment
```
    vagrant plugin install vagrant-omnibus
    vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1
    bundle install --path gems
    
    ./bin/berks install
```
6. Run the command `vagrant up`.  This will download, install, boot, and provision the VM.  This part will take a while, up to about 45 minutes depending on the speed of the host machine. Be patient.
7. Run the command `vagrant reload`.  This causes the VM to reboot and load all of the changes that were just made.
8. Run the command `vagrant ssh`.  This will ssh into the VM that is now running.
9. Import the items and and other data into the database for the UI:
```
    cd /var/www/shadowcraft-ui
    rails console production
    > Item.populate_gear("wod","wowhead_wod")
    > Item.populate_gems
    > Glyph.populate!
    > Enchant.update_from_json!
```
9. Start the ShadowCraft UI backend running by running the following commands:
    cd /var/www/shadowcraft-ui/backend
    twistd -ny server-6.0.toc &

## Editing runtime and provisioning

The environment can be modified to use other versions of the shadowcraft UI and backend as needed during the provisioning by modifying the shadowcraft-setup.sh file.  If this file is changed after the VM has already been provisioned, you may recreate the VM by running `vagrant destroy` followed by `vagrant up`.  This will completely rebuild the VM, so you'll need to restart the backend again.

The version of rails/passenger/nginx/etc can be changed by modifying the node.json file.  It currently defaults to the following versions:

* rails: 3.2.19
* nginx: 1.2.5
* passenger: 3.0.18

The same destroy/up cycle needs to happen if you change the node.json file as well.

## Running Shadowcraft from the VM

Once the VM is up and configured, you can get to the Shadowcraft UI by opening a web browser on your local machine and going to http://localhost:8080.
