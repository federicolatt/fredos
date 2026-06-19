#!/bin/bash

set -ouex pipefail

## DNF5 Speedup
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

## System apps
dnf -y install flatpak-builder lxpolkit seahorse just # libvirt virt-manager qemu-kvm wlr-randr iotop sysstat lxqt-openssh-askpass parallel  

### User apps
dnf -y install nautilus gnome-terminal gnome-system-monitor gnome-calculator loupe kitty # bitwarden-cli 
# DEV packages
# cargo evtest git input-remapper libevdev-devel libinput-utils python3-devel


## Install Gnome extensions
#https://github.com/dmy3k/auto-power-profile
#

## Install Nautilus extensions
# nautilus-open-any-terminal
#curl -Lo /etc/yum.repos.d/nautilus-open-any-terminal.repo \
#  https://copr.fedorainfracloud.org/coprs/monkeygold/nautilus-open-any-terminal/repo/fedora-$(rpm -E %fedora)/monkeygold-nautilus-open-any-terminal-fedora-$(rpm -E %fedora).repo
#dnf install -y nautilus-open-any-terminal
#glib-compile-schemas /usr/share/glib-2.0/schemas
#gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty blackbox-terminal

# install gnome-sushi (image viewer) and nautilus-admin
dnf -y install nautilus-python sushi # nautilus-admin
# nautilus-copy-path
mkdir -p /usr/share/nautilus-python/extensions/
curl -L -o /usr/share/nautilus-python/extensions/nautilus-copy-path.py \
  https://raw.githubusercontent.com/chr314/nautilus-copy-path/master/nautilus-copy-path.py

# Install Niri 
dnf -y install niri bibata-cursor-theme

# Install Noctalia shell
#curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo -o /etc/yum.repos.d/terra.repo
#dnf -y install terra-release
#dnf -y install noctalia-shell 
# ABILITARE LE NOTIFICHE: systemctl --user enable --now swaync.service

# Install Dank Linux shell
sudo curl --output-dir "/etc/yum.repos.d/" \
  --remote-name "https://copr.fedorainfracloud.org/coprs/avengemedia/dms/repo/fedora-$(rpm -E %fedora)/avengemedia-dms-fedora-$(rpm -E %fedora).repo"
#
dnf -y install dms greetd 
# Install greetd login manager with dank configuration (still needs some work)
mkdir -p /etc/greetd/
cat > /etc/greetd/config.toml << EOF
[terminal]
vt = 1
[default_session]
user = "greeter"
command = "dms-greeter --command niri"
EOF
rm -f /etc/systemd/system/display-manager.service
ln -s /usr/lib/systemd/system/greetd.service /etc/systemd/system/display-manager.service
systemctl enable --force greetd.service

mkdir -p /etc/skel/.config/systemd/user/graphical-session.target.wants
ln -s /usr/lib/systemd/user/dms.service /etc/skel/.config/systemd/user/graphical-session.target.wants/
mkdir -p /etc/skel/.config/niri/
cp -rf /ctx/dot_config/niri/config.kdl /etc/skel/.config/niri/



#### Enable podman
systemctl enable podman.socket


# Remove waybar
dnf -y remove waybar

# this is needed for some glib applications
glib-compile-schemas /usr/share/glib-2.0/schemas/

## CLEAN UP
# Clean up dnf cache to reduce image size
dnf5 -y clean all
rm -rf /run/dnf /run/selinux-policy
rm -rf /var/lib/dnf
