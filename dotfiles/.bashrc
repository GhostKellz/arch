#
# ~/.bashrc
#
# If not running interactively, don't do anything
#[[ $- != *i* ]] && return

#alias ls='ls --color=auto'
#alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ '

export KDE_NO_GALLIUM=1
export KWIN_DRM_NO_VAAPI=1
export DRI_PRIME=1
export __NV_PRIME_RENDER_OFFLOAD=1
export VDPAU_DRIVER=nvidia
export LIBVA_DRIVER_NAME=nvidia
