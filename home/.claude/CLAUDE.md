# Global instructions

## Privileged commands

`sudo` can't prompt for a password from your shell (no TTY), so don't use it.

- **Linux desktop (e.g. Omarchy/Hyprland):** use `pkexec <cmd>` instead of `sudo <cmd>`. A polkit agent shows a GUI password dialog for each command. Note that `pkexec` doesn't keep the caller's environment or working directory, so use absolute paths and pass any env vars you need explicitly (e.g. `pkexec env FOO=bar <cmd>`).
- **macOS, WSL, or if `pkexec` fails** (no polkit agent): don't try to escalate. Give me the exact command to run myself.
