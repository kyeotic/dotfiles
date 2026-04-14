# 8BitDo Controller – Rocket League Player 1 Fix

## Problem

The 8BitDo Ultimate 2C Wireless Controller was being detected as player 2/3 instead of player 1. Two unrelated devices incorrectly claim joystick slots before the controller registers:

| Slot | Device | Vendor/Product |
|------|--------|----------------|
| `js0` / `event2` | ASRock LED Controller (motherboard RGB) | `26ce:01a2` |
| `js1` / `event5` | HID 1a86:e026 (WCH USB device) | `1a86:e026` |
| `js2` / `event9` | **8BitDo Ultimate 2C Wireless Controller** | `2dc8:310a` |

Rocket League runs under Proton, which uses its own bundled SDL2 inside a container. That SDL does capability-based scanning of `/dev/input/event*` directly — the ASRock and HID device both have ABS axes and joystick-range buttons, so SDL picks them up as joysticks before the 8BitDo.

Note: `input-remapper` was not the cause. It tries to autoload a "Rocket Legaue" preset for the 8BitDo but the preset file doesn't exist, so it never grabs the device.

## Fix

### Steam launch option (the actual fix)

In Steam → Rocket League → Properties → Launch Options:

```
SDL_GAMECONTROLLER_IGNORE_DEVICES=0x26CE/0x01A2,0x1A86/0xE026 %command%
```

This tells SDL to ignore the ASRock and HID devices as game controllers regardless of their capabilities. It works inside Proton's container because it's an environment variable, not a udev property lookup.

### udev rules (cleanup — keeps jsN slots tidy)

`/etc/udev/rules.d/99-no-fake-joysticks.rules` — removes jsN nodes and marks devices as non-joystick for system SDL apps:

```
# ASRock LED Controller - not a joystick
SUBSYSTEM=="input", ATTRS{idVendor}=="26ce", ATTRS{idProduct}=="01a2", ENV{ID_INPUT_JOYSTICK}="0"
SUBSYSTEM=="input", KERNEL=="js[0-9]*", ATTRS{idVendor}=="26ce", ATTRS{idProduct}=="01a2", RUN+="/bin/rm /dev/input/%k"

# HID 1a86:e026 (WCH USB device) - not a joystick
SUBSYSTEM=="input", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="e026", ENV{ID_INPUT_JOYSTICK}="0"
SUBSYSTEM=="input", KERNEL=="js[0-9]*", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="e026", RUN+="/bin/rm /dev/input/%k"
```

`/etc/udev/rules.d/99-8bitdo-js0.rules` — symlinks the 8BitDo to js0 (already existed):

```
SUBSYSTEM=="input", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="310a", SYMLINK+="input/js0"
```

---

# 8BitDo Controller – PTT Pass-Through (Discord Push-to-Talk)

## Problem

A controller button needs to simultaneously:
1. Send the original Xbox gamepad button so Rocket League sees it normally
2. Send `KEY_F13` (held, not just tapped) so Discord can use it as push-to-talk

input-remapper can't do both — it *grabs* the device and the original event is consumed.

## Fix: evdev pass-through script

Two scripts in `bazzite/controller/`:

- `8bitdo-ptt.py` — grabs the real 8BitDo and creates **two** virtual devices:
  - **Virtual gamepad** (`8BitDo Ultimate 2C (PTT)`) — mirrors all capabilities, vendor/product unchanged. Steam/Proton/Rocket League use this.
  - **Virtual keyboard** (`8BitDo PTT Keyboard`) — emits only `KEY_F13`. Discord sees this as a normal keyboard.
- `8bitdo-ptt.service` — systemd unit that runs the script as root on boot.

When `BTN_TR` (right bumper) or `BTN_THUMBL` (left stick click) is pressed, both the original gamepad button and `KEY_F13` are emitted simultaneously. Hold works correctly — F13 stays down until the button is released.

The real device is grabbed (invisible to other processes). input-remapper must have Autoload disabled for the 8BitDo or the grab will conflict.

**To add/change PTT buttons**, edit `PTT_BUTTONS` in `8bitdo-ptt.py`. Run `evtest` on the real device to find button codes.

**Disable input-remapper autoload** for the 8BitDo — the two will conflict since both try to grab the device. In input-remapper, open the Rocket League preset and toggle Autoload off.

### Why two virtual devices?

Discord only listens for keyboard shortcuts on devices that look like keyboards. Emitting `KEY_F13` from the gamepad virtual device (which has ABS axes and gamepad vendor/product) is ignored by Discord. A separate minimal keyboard device — with no gamepad capabilities — is recognized correctly.

### Installation

Bazzite is an immutable OS. Use `rpm-ostree` to layer the package — requires one reboot:

```bash
sudo rpm-ostree install python3-evdev
systemctl reboot
```

After reboot, run the install script. Re-run any time the `.py` or `.service` changes:

```bash
install-xinput
# or: sudo bash ~/dotfiles/bazzite/controller/install.sh
```

### Discord setup

In Discord → Settings → Voice & Video → Push to Talk, record the shortcut — press the right bumper or left stick click. It should appear as `F13`.

### Verify it's working

```bash
# Check service status and startup logs
sudo systemctl status 8bitdo-ptt --no-pager
sudo journalctl -u 8bitdo-ptt -n 20 --no-pager

# Confirm both virtual devices exist
grep -A 3 "PTT" /proc/bus/input/devices
```

---

## Re-applying After a Reinstall

1. Copy the two udev rules files to `/etc/udev/rules.d/` and run:
   ```bash
   sudo udevadm control --reload-rules
   ```

2. Add the Steam launch option to Rocket League:
   ```
   SDL_GAMECONTROLLER_IGNORE_DEVICES=0x26CE/0x01A2,0x1A86/0xE026 %command%
   ```
