# VirtualBox with Linux UEFI/secure boot

## Abstract
To load the virtual box driver when secure boot enabled, we need it to be signed.
The basic idea is to [create a mock up CA and use it to sign the compiled modules](http://gorka.eguileor.com/vbox-vmware-in-secureboot-linux/);
[or this version](https://gist.githubusercontent.com/gabrieljcs/68939c7eeadfabfdbc6b40100130270d/raw/e1b1c44fe99090ca90ece47c79396775a97dfd41/vm-secureboot.md).

### Note

The driver sign needs to be automated, otherwise it has to be redone each time we install a new kernel. While this can be archived with may options, I opted to patch the installer script as it requires the least amount of extra things.

## Requirements

- Linux system with secure boot enabled. I tested with Fedora; it should work on all rpm based systems. (Debian should also work, [kernel headers path](https://github.com/helge000/virtualbox-drv/blob/master/vboxdrv.patch#L41) needs to be altered IIRC). 
- Upstream [Virtual Box 5.2 installation](https://www.virtualbox.org/wiki/Downloads); versions from RPM Fusion do not work

## One time steps

1. `git clone https://github.com/helge000/virtualbox-drv.git` this repository
2. Generate a pair of mok certificates to sign the driver:
```bash
openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=VirtualBox MOK cert/"
```
3. Copy `MOK.priv` and `MOK.der` to a static location; eg `/etc/drv-sign` and modify `$BASEDIR` in `./vboxdrv.patch` accordingly
4. Run `mokutil --import MOK.der`, enter arbitrary  password
5. Reboot your computer and complete the cert enrolment (remember the password from step 3)

## Steps to be repeated each time Virtual Box is updated

1. To sign new drivers, patch the install script to have it sign the modules in the `setup` part:
```bash
sudo patch /usr/lib/virtualbox/vboxdrv.sh ./vboxdrv.patch
```
2. Rerun setup: `/usr/lib/virtualbox/vboxdrv.sh setup` and note the output about signed modules

### Option: Install extention pack

- Run `./install_extpack.sh` to download and install the extension pack for your VirtualBox version (requires vboxdrv actually loaded)
