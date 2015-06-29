shadowcraft-vm
==============

Vagrant configuration for running [Shadowcraft-UI](https://github.com/cheald/shadowcraft-ui) and [Shadowcraft-Engine](https://github.com/dazer/ShadowCraft-Engine).  See those projects for more information about what they do individually.

Setting up, using, and updating this virtual machine requires some knowledge of how Linux systems work and functioning knowledge of how to use a Linux shell.

## Installation

### Linux/OS X Vagrant Setup/Configuration

1. Install Vagrant from [http://vagrantup.com](http://vagrantup.com)
2. Install Virtualbox from [http://virtualbox.org](http://virtualbox.org)
3. Clone this repo
4. Open a command line (xterm, Terminal.app, etc) and enter the directory of the repo
5. Run the following commands to initialize the vagrant environment:
```
    vagrant plugin install vagrant-omnibus
    vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1
    bundle install --path gems
```

### Windows Vagrant Setup/Configuration

1. Install Vagrant from [http://vagrantup.com](http://vagrantup.com)
2. Install Virtualbox from [http://virtualbox.org](http://virtualbox.org)
3. Copy bsdtar.exe from C:\HashiCorp\Vagrant\embedded\bin to C:\HashiCorp\Vagrant\bin and name it tar.exe.
4. Clone this repo
5. Open a command line (cmd.exe) and enter the directory of the cloned repo
6. Run the following commands to initialize the vagrant environment:
```
    vagrant plugin install vagrant-omnibus
    vagrant plugin install vagrant-berkshelf --plugin-version 2.0.1
    set PATH=%PATH%;C:\HashiCorp\Vagrant\embedded\bin
    bundle install --path gems
```

## Shadowcraft-VM Installation

1. Run the command `vagrant up`.  This will download, install, boot, and provision the VM.  This part will take a while, up to about 45 minutes depending on the speed of the host machine. Be patient.
2. Run the command `vagrant reload`.  This causes the VM to reboot and load all of the changes that were just made.
3. SSH into the now-running VM:
   - On Linux/OS X, run the command `vagrant ssh`.
   - On Windows, run the command `vagrant ssh`.  This will fail but it will give you the information you need to use to connect to the VM using an SSH client such as PuTTY or SuperTerm.
4. Within the ssh session, add your Blizzard API key to the Shadowcraft-UI configuration so that data can be imported from the API.  Edit the /var/www/shadowcraft-ui/config/auth_key.yml (or add the file if it doesn't exist) and make sure there's a line that starts with 'apikey' that is set to your key from https://dev.battle.net/io-docs.  Replace the line if one already exists.
5. Within the ssh session, import the items and and other data into the database for the UI:
```
    cd /var/www/shadowcraft-ui
    sudo rails console development
    > Item.populate_gear_wod
    > Item.populate_gems_wod
    > Glyph.populate!
    > Enchant.update_from_json!
```
6. Within the ssh session, start the ShadowCraft UI backend running by running the following commands:
```
    cd /var/www/shadowcraft-ui/backend
    sudo twistd -ny server-6.0.tac &
```

## Editing runtime and provisioning

The environment can be modified to use other versions of the shadowcraft UI and backend as needed during the provisioning by modifying the shadowcraft-setup.sh file.  If this file is changed after the VM has already been provisioned, you may recreate the VM by running `vagrant destroy` followed by `vagrant up`.  This will completely rebuild the VM, so you'll need to restart the backend again.

The version of rails/passenger/nginx/etc can be changed by modifying the node.json file.  It currently defaults to the following versions:

* rails: 3.2.19
* nginx: 1.2.5
* passenger: 3.0.18

The same destroy/up cycle needs to happen if you change the node.json file as well.

## Running Shadowcraft from the VM

Once the VM is up and configured, you can get to the Shadowcraft UI by opening a web browser on your local machine and going to `http://localhost:8080`.

## Updating Shadowcraft-Engine

Updates come out for the engine code periodically and you must update your installation manually.  This is easy to do from an ssh session to the VM.  Run these commands from a root shell on the VM:
```
    cd /usr/local/ShadowCraft-Engine
    git pull
    cd scripts
    ./reinstall.sh
```

## Updating Shadowcraft-UI

Updates come out for the UI code periodically and you must update your installation manually.  This is possible via an ssh session to the VM but requires more work than updating the engine.  It's preferred that you update the engine before updating the UI if necessary.  Run these commands from a root shell on the VM:
```
	cd /var/www/shadowcraft-ui
	git pull
	ps -ef | grep twistd
	kill <the pid from the previous command>
	cd /var/www/shadowcraft/backend
	twistd -ny server-6.0.tac &
	rm /var/www/shadowcraft/items-rogue.js
	service nginx restart
```
At this point the UI code is updated and the services to run it are restarted.  If there were major changes to the UI code, it's suggested that you also dump and reload the database.  Run these commands from a root shell on the VM:
```
	mongo
	> use roguesim_development
	> db.dropDatabase()
	> exit
	cd /var/www/shadowcraft-ui
	rails console development
	> Item.populate_gear_wod
	> Item.populate_gems_wod
	> Glyph.populate!
	> Enchant.update_from_json!
	> exit
	rm /var/www/shadowcraft/public/items-rogue.js
	service nginx restart
```
Due to a new changeover to using the Blizzard API for item data, the load will take quite some time.  Be patient.
