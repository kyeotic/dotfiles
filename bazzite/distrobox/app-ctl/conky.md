# Conky in app-ctl

Conky runs inside the `app-ctl` distrobox container via `conky.service`, using `podman exec` to launch it.

## nvidia-smi wrapper

The host's nvidia-smi binary (`/usr/bin/nvidia-smi`) cannot be called directly from inside the container — it needs the host's full glibc/library stack and the container's dynamic linker can't satisfy it.

The wrapper at `~/.local/bin/nvidia-smi` handles this by detecting whether it's running inside a container and routing accordingly:

```bash
#!/bin/bash
if [ -f /run/.containerenv ]; then
    /usr/bin/host-spawn /usr/bin/nvidia-smi "$@"
else
    /usr/bin/nvidia-smi "$@"
fi | tr -d '\r'
```

- `/run/.containerenv` is created by podman and reliably indicates a container environment
- `host-spawn` (available at `/usr/bin/host-spawn` inside the container, not on the host) spawns the process in the host environment
- The explicit `/usr/bin/nvidia-smi` path avoids the circular reference that would occur if `host-spawn` resolved `nvidia-smi` through PATH (which would find this wrapper again)
- `tr -d '\r'` strips CRLF line endings that nvidia-smi outputs; without this, shell arithmetic (`$((USED * 100 / TOTAL))`) fails with "invalid arithmetic operator"

## conky.service PATH

`podman exec` does not source the user's profile, so `~/.local/bin` is not in PATH. Conky must be launched through a login shell to get the correct PATH:

```
bash -l -c "conky -c /path/to/conky.conf"
```

Without `bash -l`, conky can't find the nvidia-smi wrapper and all GPU stats come back empty.
