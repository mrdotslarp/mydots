#!/usr/bin/env bash

## --- STAGE 1: CORE REPOSITORIES ---
sudo pacman -S --needed --noconfirm bspwm sxhkd polybar rofi dmenu procps brightnessctl pamixer playerctl xorg-xkill xorg-xrandr xsel xclip xterm konsole dolphin chromium htop networkmanager feh scrot xorg-server xorg-xinit xf86-input-libinput xorg-xprop xorg-xwininfo bleachbit materia-gtk-theme lightdm lightdm-gtk-greeter ttf-font-awesome adobe-source-han-sans-jp-fonts ttf-iosevka-nerd gwenview git nano curl wget less rust net-tools krita libdbusmenu-gtk3 libdbusmenu-qt5 qt6ct qt5ct breeze breeze-icons intel-media-driver xorg-xinput

## --- STAGE 2: AUR HELPER & PACKAGES ---

## ---- YAY PKGMGR INSTALLATION ---- ##

git clone https://aur.archlinux.org/yay.git ~/yay

cd ~/yay

makepkg -si --noconfirm

## ---- YAY PACKAGES ---- ##

yay -S --needed --noconfirm whitesur-icon-theme vibrant-cli neofetch cava

## --- STAGE 3: CONFIGURATION DEPLOYMENT ---
# Ensure ~/.config exists
mkdir -p ~/.config

# Copy main config directory
if [[ -d "config" ]]; then
    cp -r config/* ~/.config/
    log_success "Main config files copied."
else
    log_error "Directory 'config' not found. Ensure you are running this from your Dotfiles folder."
fi

# Copy specific dotfiles if they exist
[[ -f "fetch.Xresources" ]] && cp fetch.Xresources ~/.Xresources && log_info "Xresources deployed."
[[ -f "fetch.bashrc" ]] && cp fetch.bashrc ~/.bashrc && log_info "Bashrc deployed."

## --- STAGE 4: PERMISSIONS & EXECUTABLES ---
log_info "Setting executable permissions for scripts..."

sudo chmod +x .config/bspwm/bspwmrc
sudo chmod +x .config/bspwm/log.sh
sudo chmod +x .config/bspwm/screen.sh
sudo chmod +x .config/bspwm/wall.sh
sudo chmod +x .config/bspwm/nekowall.sh
sudo chmod +x .config/bspwm/fzz.sh
sudo chmod +x .config/bspwm/fan.sh

## --- STAGE 5: SYSTEM ASSETS & LIGHTDM ---
log_info "Configuring LightDM and system backgrounds..."

sudo mkdir -p /usr/share/backgrounds

# ---- ## ---- #

sudo cp wallpaper.jpg /usr/share/backgrounds/
sudo cp pfp.jpg /usr/share/backgrounds/

# ---- ## ---- #

    sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null <<EOF
[greeter]
# Background & User Avatar
background = /usr/share/backgrounds/wallpaper.jpg
user-background = false
default-user-image = /usr/share/backgrounds/pfp.jpg
hide-user-image = false
round-user-image = true

# Theme & Typography
theme-name = Materia-dark
icon-theme-name = Adwaita
cursor-theme-name = Bibata-Modern-Ice
cursor-theme-size = 24
font-name = JetBrainsMono Nerd Font 10
xft-antialias = true
xft-hintstyle = hintslight
xft-rgba = rgb

# Layout & Positioning (Centered login box, minimal top panel)
position = 50%,center 50%,center
default-user-image-size = 96
panel-position = top
indicators = ~host;~spacer;~clock;~spacer;~session;~power

# Clock & Power
clock-format = %a %b %d  •  %H:%M
screensaver-timeout = 300
EOF

# Enable the LightDM service so it actually starts on boot
    sudo systemctl enable lightdm.service
    log_success "LightDM configured and enabled."
else
    log_info "System images (wallpaper.jpg/pfp.jpg) missing. Skipping LightDM visual config."
fi

##
xrdb .Xresources

##
log_success "Installation Complete! Please reboot to enter your new environment."
