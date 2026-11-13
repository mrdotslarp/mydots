#!/usr/bin/env bash

sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol helvum qpwgraph pamixer

## --- STAGE 2: SERVICE MANAGEMENT ---

# Stop and disable PulseAudio services to prevent conflicts
systemctl --user stop pulseaudio.service pulseaudio.socket 2>/dev/null
systemctl --user disable pulseaudio.service pulseaudio.socket 2>/dev/null

# Enable and start PipeWire/Wireplumber services
systemctl --user enable pipewire.service wireplumber.service pipewire-pulse.service
systemctl --user start pipewire.service wireplumber.service pipewire-pulse.service

log_success "Audio services transitioned."

## ---

# Set default volume to 40% for both Sink and Source
wpctl set-volume @DEFAULT_AUDIO_SINK@ 40%
wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 40%
