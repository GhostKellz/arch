# OBS Studio configuration

The public-safe `GhostKellz` profile provides a conservative 1080p60 baseline:

- NVIDIA NVENC for streaming and recording
- 6 Mbps video and 192 Kbps AAC audio
- MKV recording so an interrupted session does not corrupt the whole recording
- Rec. 709 limited-range SDR video
- 48 kHz stereo audio

OBS Studio on Arch includes its PipeWire screen-capture, NVENC, and WebSocket
plugins. The workstation bootstrap also installs the KDE and GTK XDG desktop
portal backends, `kpipewire`, GStreamer support, and the official-repository
background-removal plugin. Select the `GhostKellz` profile in OBS after the
first launch; scenes and audio/video devices remain intentionally manual.

The following stay local and must never be copied into this public repository:

- stream service profiles and keys
- WebSocket credentials
- scene collections and browser-source URLs
- cookies, plugin authentication, logs, and profiler captures

The optional `--with-obs-virtual-camera` bootstrap flag installs
`v4l2loopback-dkms` and its utilities. It is separate because it builds an
out-of-tree kernel module and therefore requires matching headers. Do not run
that DKMS build while a CachyOS-LTO kernel or NVIDIA module build is active.
