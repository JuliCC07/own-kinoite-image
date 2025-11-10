# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/kinoite-nvidia:latest

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

## Drivers y utilidades hardware
RUN rpm-ostree install \
    acpid \
    vulkan-loader \
    vulkan-loader.i686 \
    powertop \
    tuned-utils \
    tlp \
    kernel-tools \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers.i686 \
    amd-gpu-firmware
## Virt-manager
RUN rpm-ostree install \ 
	libvirt-daemon-driver-network \
	libvirt-daemon-config-network \
	libvirt-daemon-kvm \
	libvirt-daemon-driver-nodedev \
	libvirt-daemon-driver-qemu \
	libvirt-daemon-driver-storage-core \
	qemu-audio-spice \
	qemu-char-spice \
	qemu-device-display-qxl \
	qemu-device-display-virtio-gpu \
	qemu-device-display-virtio-vga \
	qemu-device-usb-redirect \
	qemu-system-x86-core \
	spice-server \
	spice-gtk \
	virt-viewer \
	qemu-kvm \
	virt-manager

## Terminal y herramientas

RUN rpm-ostree install \
	kitty \
	neovim \
	fastfetch \
	gh \
	qemu \
	git-lfs \
	pip

## Eliminar de KDE
RUN rpm-ostree override remove \
	firefox \
	firefox-langpacks \
	konsole \
	khelpcenter \
	kinfocenter \
	plasma-welcome

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

## Habilitar y deshabilitar servicios
RUN systemctl disable tlp.service
RUN systemctl enable tuned.service

RUN rpm-ostree cleanup -m && \
    rm -rf /var/cache/*
