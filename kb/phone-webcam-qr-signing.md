# Phone as a Webcam for QR-Based Hardware Wallet Signing

How to use a phone's rear camera as a regular V4L2 webcam on Arch, for air-gapped hardware wallets that sign via QR codes (e.g. Keystone 3 Pro with MetaMask or XRP Toolkit in a Chromium-based browser).

Desk webcams are tuned for faces at arm's length. Autofocus tends to hunt on a bright screen held close, and animated QR codes fail to decode. A phone rear camera focuses close and handles screen glare far better.

Only unsigned transaction requests and signatures travel as QR codes, never seed material. Prefer the USB path below over Wi-Fi so the video never crosses the network.

## How it works

```
Phone camera app (MJPEG server)
  → USB (usbmuxd + iproxy on iOS / adb on Android)
  → ffmpeg
  → v4l2loopback virtual device
  → browser camera picker
```

## Packages

```bash
sudo pacman -S --needed ffmpeg v4l2loopback-dkms v4l-utils
# iPhone
sudo pacman -S --needed usbmuxd libimobiledevice
# Android alternative: scrcpy can write straight to v4l2loopback
sudo pacman -S --needed scrcpy android-tools
```

`v4l2loopback-dkms` builds against the headers of **your running kernel**. Install the headers package that matches it (e.g. `linux-headers` for stock `linux`, or the matching `*-headers` for a custom kernel), not a mismatched one.

## iPhone (USB)

Phone app: any app that serves an MJPEG stream over HTTP, e.g. **DroidCam** (port 4747) or **IP Camera Lite** (port 8081). Search carefully, since many similarly named apps are *viewers*, not servers.

**iOS requirement:** Settings → Privacy & Security → Local Network → enable the app. Without it the app's port is closed even though the phone answers pings.

Keep the app in the foreground with the phone unlocked; iOS suspends the server otherwise.

```bash
# trust the computer on the phone, then confirm pairing
idevicepair validate

# virtual camera
sudo modprobe v4l2loopback video_nr=9 card_label="Phone Cam" exclusive_caps=1

# tunnel the app's port over USB
iproxy 4747 4747 &

# feed the stream into the virtual camera
ffmpeg -i http://127.0.0.1:4747/video \
  -vf "scale=-2:1080,format=yuv420p" -f v4l2 /dev/video9
```

For apps that require a login, put it in the URL: `http://user:pass@127.0.0.1:PORT/video`.

## Android (USB)

```bash
sudo modprobe v4l2loopback video_nr=9 card_label="Phone Cam" exclusive_caps=1
scrcpy --video-source=camera --camera-facing=back --camera-size=1920x1080 \
  --v4l2-sink=/dev/video9 --no-video-playback
```

Requires USB debugging enabled on the phone.

## Verify

```bash
v4l2-ctl --list-devices                       # "Phone Cam" at /dev/video9
v4l2-ctl -d /dev/video9 --all | grep -E 'Width|Pixel'
wpctl status                                  # Video → Sources should list "Phone Cam"
```

Then in the browser, choose **Phone Cam** in the site's camera prompt. Hold the wallet ~15–25 cm from the lens.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Browser doesn't list the virtual camera | Missing `exclusive_caps=1` | Reload module with it |
| Still missing after "restarting" browser | Browser kept running in the background | Fully quit (`brave://restart`, `chrome://restart`, or kill the process) |
| Still missing after a real restart | WirePlumber saw the device before it was fed; no source node | `systemctl --user restart wireplumber`, then restart the browser |
| `Connection reset by peer` from ffmpeg | Phone app allows one client at a time | Close other viewers/probes and retry |
| Phone ports closed (iOS) | Local Network permission off, or app backgrounded | Enable permission; keep app on screen |

## Persisting the virtual camera

```bash
echo v4l2loopback | sudo tee /etc/modules-load.d/v4l2loopback.conf
echo 'options v4l2loopback video_nr=9 card_label="Phone Cam" exclusive_caps=1' \
  | sudo tee /etc/modprobe.d/v4l2loopback.conf
```

## Improving a desk webcam instead

If a phone isn't handy, locking focus and lowering exposure often makes a UVC webcam usable for QR scanning:

```bash
v4l2-ctl -d /dev/video0 --list-ctrls
v4l2-ctl -d /dev/video0 -c focus_automatic_continuous=0 -c focus_absolute=300
v4l2-ctl -d /dev/video0 -c auto_exposure=1 -c exposure_time_absolute=60
```

Control names and ranges vary by camera; check `--list-ctrls` first.
