# shadowcraft-vm

Vagrant configuration for running
[Shadowcraft-UI](https://github.com/cheald/shadowcraft-ui) and
[Shadowcraft-Engine](https://github.com/dazer/ShadowCraft-Engine). See those
projects for more information about what they do individually.

Setting up, using, and updating this virtual machine requires some knowledge of
how Linux systems work and functioning knowledge of how to use a Linux shell.

## Installation

### Setting Up Vagrant (OSX/Linux)

  1. Install Vagrant from http://vagrantup.com
  2. Install Virtualbox from http://virtualbox.org

### Setting Up Vagrant (Windows)

  1. Install Vagrant from http://vagrantup.com
  2. Install Virtualbox from http://virtualbox.org
  3. Copy bsdtar.exe from `C:\HashiCorp\Vagrant\embedded\bin` to
     `C:\HashiCorp\Vagrant\bin and name it tar.exe`
  4. Clone this repo
  5. Open a command line (cmd.exe) and enter the directory of the cloned repo
  6. Run the following commands to initialize the vagrant environment:

    set PATH=%PATH%;C:\HashiCorp\Vagrant\embedded\bin

## Shadowcraft-VM Installation

  1. Clone this repository (`git clone
     git@github.com:timwoj/shadowcraft-vm.git`)
  2. Run the command `vagrant up`. This will download, install, boot, and
     provision the VM. This part will take a while, up to about 45 minutes
     depending on the speed of the host machine. Be patient.
  3. Run the command `vagrant reload`. This causes the VM to reboot and load
     all of the changes that were just made.
  4. SSH into the now-running VM:
     - On Linux/OS X, run the command `vagrant ssh`.
     - On Windows, run the command `vagrant ssh`. This will fail but it will
       give you the information you need to use to connect to the VM using an
       SSH client such as PuTTY or SuperTerm.

### Blizzard API Key

Within the SSH session you will need to register at
https://dev.battle.net/io-docs to get an API key. Follow the instructions on
the site and get the API key.

You can then add the API key to `/var/www/shadowcraft-ui/config/auth_key.yml`
with the following contents

```yaml
---
apikey: [your key goes here]
```

### Importing Game Data

Within the SSH session you will need to import the game data.

    cd /var/www/shadowcraft-ui sudo rails console development
    > Item.populate_gear_wod
    > Item.populate_gems_wod
    > Glyph.populate!
    > Enchant.update_from_json!

## Editing runtime and provisioning

The environment can be modified to use other versions of the shadowcraft UI and
backend as needed during the provisioning by modifying the
`shadowcraft-setup.sh` file. If this file is changed after the VM has already
been provisioned, you may recreate the VM by running `vagrant destroy` followed
by `vagrant up`. This will completely rebuild the VM.

The version of rails can be changed by modifying the `apt_packages.sh` file. It
currently defaults to version 3.2.19. The same destroy/up cycle needs to happen
if you change the `apt_packages.sh` file as well.

## Running Shadowcraft from the VM

Once the VM is up and configured, you can get to the Shadowcraft UI by opening a
web browser on your local machine and going to `http://localhost:8080`.

## Updating Shadowcraft-Engine

Updates come out for the engine code periodically and you must update your
installation manually. This is easy to do from an SSH session to the VM. Run
these commands from a root shell on the VM:

    cd /usr/local/ShadowCraft-Engine
    git pull
    cd scripts
    ./reinstall.sh

## Updating Shadowcraft-UI

Updates come out for the UI code periodically and you must update your
installation manually. This is possible via an SSH session to the VM but
requires more work than updating the engine. It's preferred that you update the
engine before updating the UI if necessary. Run these commands from a root
shell on the VM:

    cd /var/www/shadowcraft-ui
    git pull
    ps -ef | grep twistd
    kill <the pid from the previous command>
    cd /var/www/shadowcraft/backend
    ./restart.sh
    rm /var/www/shadowcraft/items-rogue.js
    service nginx restart

At this point the UI code is updated and the services to run it are restarted.
If there were major changes to the UI code, it's suggested that you also dump
and reload the database. Run these commands from a root shell on the VM:

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

Due to a new changeover to using the Blizzard API for item data, the load will
take quite some time. Be patient.
