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

## Re-applying After a Reinstall

1. Copy the two udev rules files to `/etc/udev/rules.d/` and run:
   ```bash
   sudo udevadm control --reload-rules
   ```

2. Add the Steam launch option to Rocket League:
   ```
   SDL_GAMECONTROLLER_IGNORE_DEVICES=0x26CE/0x01A2,0x1A86/0xE026 %command%
   ```
