#!/bin/bash

set -euxo pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos

dnf5 install -y tmux 

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

dnf5 -y copr enable ublue-os/staging
dnf5 -y copr enable sunwire/envycontrol

dnf5 -y install python-envycontrol

dnf5 -y copr disable ublue-os/staging
dnf5 -y copr disable sunwire/envycontrol

# LenovoLegionLinux
# dnf5 -y copr enable mrduarte/LenovoLegionLinux
# dnf5 -y install python-LenovoLegionLinux
# dnf5 -y copr disable mrduarte/LenovoLegionLinux
git clone https://github.com/johnfanv2/LenovoLegionLinux.git
cd LenovoLegionLinux/kernel_module
make
install -Dm644 legion-laptop.ko /usr/lib/modules/<kernel>/kernel/drivers/platform/x86/

#### Example for enabling a System Unit File

systemctl enable podman.socket
