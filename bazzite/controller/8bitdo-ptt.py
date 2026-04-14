#!/usr/bin/env python3
"""
8BitDo Ultimate 2C - PTT (Push-to-Talk) Pass-Through

Creates two virtual devices:
  - A virtual gamepad mirroring the 8BitDo  → Rocket League sees all buttons normally
  - A virtual keyboard with only KEY_F13     → Discord sees it as a real keyboard key

When TRIGGER_BTN is pressed/released, both the gamepad button and KEY_F13 are emitted.
Hold behavior works correctly — both stay pressed until the button is released.
"""

import sys
import signal
import evdev
from evdev import InputDevice, UInput, ecodes

# 8BitDo Ultimate 2C Wireless Controller
VENDOR_ID  = 0x2dc8
PRODUCT_ID = 0x310a

# Buttons that also emit F13 on the virtual keyboard (for Discord PTT).
# BTN_TR = right bumper, BTN_THUMBL = left stick click.
# Run `evtest` on the real device to find codes for other buttons.
PTT_BUTTONS = {ecodes.BTN_TR, ecodes.BTN_THUMBL}


def find_controller():
    """Find the main gamepad interface (the one with ABS axes, not the mouse)."""
    for path in evdev.list_devices():
        try:
            dev = InputDevice(path)
            if dev.info.vendor == VENDOR_ID and dev.info.product == PRODUCT_ID:
                if ecodes.EV_ABS in dev.capabilities():
                    return dev
            dev.close()
        except (PermissionError, OSError):
            continue
    return None


def main():
    controller = find_controller()
    if not controller:
        print("Error: 8BitDo Ultimate 2C not found", file=sys.stderr)
        sys.exit(1)

    print(f"Found: {controller.name} at {controller.path}")

    # Virtual gamepad: mirrors the 8BitDo for Rocket League/Steam.
    # Filter out EV_SYN, EV_FF, EV_MSC — uinput handles SYN internally,
    # FF requires special setup, both cause EINVAL if enabled explicitly.
    pad_caps = controller.capabilities(absinfo=True)
    for skip in (ecodes.EV_SYN, ecodes.EV_FF, ecodes.EV_MSC):
        pad_caps.pop(skip, None)

    virtual_pad = UInput(pad_caps, name="8BitDo Ultimate 2C (PTT)", vendor=VENDOR_ID, product=PRODUCT_ID)
    print(f"Created virtual gamepad: 8BitDo Ultimate 2C (PTT)")

    # Virtual keyboard: only KEY_F13, looks like a keyboard to Discord.
    virtual_kb = UInput({ecodes.EV_KEY: [ecodes.KEY_F13]}, name="8BitDo PTT Keyboard")
    print(f"Created virtual keyboard: 8BitDo PTT Keyboard")

    def cleanup(signum=None, frame=None):
        print("\nShutting down...")
        try:
            controller.ungrab()
        except Exception:
            pass
        virtual_pad.close()
        virtual_kb.close()
        sys.exit(0)

    signal.signal(signal.SIGTERM, cleanup)
    signal.signal(signal.SIGINT, cleanup)

    controller.grab()
    print(f"Grabbed {controller.path} — forwarding events")
    print(f"PTT buttons → gamepad button (Rocket League) + KEY_F13 on keyboard device (Discord PTT)")

    try:
        for event in controller.read_loop():
            if event.type == ecodes.EV_KEY and event.code in PTT_BUTTONS:
                # Gamepad gets the original button
                virtual_pad.write(ecodes.EV_KEY, event.code, event.value)
                # Keyboard device gets F13 (value: 0=release, 1=press, 2=repeat)
                virtual_kb.write(ecodes.EV_KEY, ecodes.KEY_F13, event.value)
                virtual_kb.syn()
                # SYN for the pad comes from the next EV_SYN in read_loop
            else:
                virtual_pad.write_event(event)
    except OSError as e:
        print(f"Device lost: {e}", file=sys.stderr)
        cleanup()


if __name__ == "__main__":
    main()
