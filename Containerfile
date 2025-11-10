# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/kinoite-main:latest

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

# --- Metadatos ---
LABEL org.opencontainers.image.title="Legion-Kinoite-RTX-4070"
LABEL org.opencontainers.image.description="Imagen personalizada de Fedora Kinoite para Lenovo Legion 5 Pro Gen 8 (RTX 4070 / Ryzen 9 7945HX / 240Hz)"
LABEL org.opencontainers.image.vendor="JuliCC07/own-kinoite-image"


### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN rpm-ostree install \
    acpid \
    akmod-nvidia \
    xorg-x11-drv-nvidia-cuda \
    xorg-x11-drv-nvidia-libs \
    xorg-x11-drv-nvidia-libs.i686 \
    vulkan-loader \
    vulkan-loader.i686 \
    libva-nvidia-driver \
    libvirt-daemon-config-network \
    libvirt-daemon-kvm \
    lm-sensors \
    python-envycontrol \
    qemu-kvm \
    virt-manager \
    powertop \
    tuned-utils \
    kernel-tools \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers.i686 \
    amd-gpu-firmware \
    kitty

RUN rpm-ostree override remove \
	firefox \
	firefox-langpacks

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh
    
### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

RUN rpm-ostree cleanup -m && \
    rm -rf /var/cache/*
