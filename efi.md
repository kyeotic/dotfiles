# PopOS Efi Setup


First, copy the Windows EFI over
```bash
# Mount the Windows EFI partition
sudo mkdir -p /mnt/windows-efi
sudo mount /dev/nvme0n1p1 /mnt/windows-efi

# Copy the Windows bootloader structure
sudo mkdir -p /boot/efi/EFI/Microsoft/Boot
sudo cp -r /mnt/windows-efi/EFI/Microsoft/Boot/* /boot/efi/EFI/Microsoft/Boot/

# Check what we copied
sudo ls -la /boot/efi/EFI/Microsoft/Boot/

# Unmount the Windows partition
sudo umount /mnt/windows-efi
```


- /boot/efi/loader/loader.conf
```
default Pop_OS-current
timeout 5
console-mode max
editor no
# auto-entries no
```
