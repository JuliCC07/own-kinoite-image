#!/bin/bash

set -ouex pipefail

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

# Hardware-related Drivers
dnf5 install -y \
	acpid \
	akmod-nvidia \
	libvirt-daemon-config-network \
	libvirt-daemon-kvm \
	lm-sensors \
	python-envycontrol \
	qemu-kvm \
	virt-manager \
	xorg-x11-drv-nvidia-cuda \
	xorg-x11-drv-nvidia-cuda-libs
	powertop \
	tuned-utils\

# LenovoLegionLinux
#dnf5 -y copr enable mrduarte/LenovoLegionLinux
#dnf5 -y install dkms-LenovoLegionLinux
#dnf5 -y copr disable mrduarte/LenovoLegionLinux

#### Example for enabling a System Unit File

systemctl enable podman.socket
