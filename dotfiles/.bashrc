#
# ~/.bashrc
#
# If not running interactively, don't do anything
#[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
#alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ '

### NVIDIA ENVIRONMENT VARIABLES ###

# Disable fallback drivers that conflict with NVIDIA (Wayland + KDE-specific)
export KDE_NO_GALLIUM=1
export KWIN_DRM_NO_VAAPI=1

# Force NVIDIA as the Wayland renderer
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia

# Hardware acceleration for media
export VDPAU_DRIVER=nvidia
export LIBVA_DRIVER_NAME=nvidia

# PRIME offloading (for hybrid GPU setups — optional if desktop with single GPU)
export DRI_PRIME=1
export __NV_PRIME_RENDER_OFFLOAD=1
export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0  # Only if you're sure this is the correct provider

# NVIDIA GL rendering behavior
export __GL_YIELD="USLEEP"             # Lower latency
export __GL_SYNC_TO_VBLANK="1"         # Sync to monitor refresh rate
