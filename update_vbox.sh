#!/bin/bash
# Run this after upgrading Virtual Box
cp /usr/lib/virtualbox/vboxdrv.sh /usr/lib/virtualbox/vboxdrv.sh.org
patch /usr/lib/virtualbox/vboxdrv.sh vboxdrv.patch \
  && /usr/lib/virtualbox/vboxdrv.sh setup \
  && ./install_extpack.sh

