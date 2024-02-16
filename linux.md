# Installed

* zsh, oh-my-zsh
* Ksnip - Screenshots
* xone - Xbox Controller Driver
* Autokey - Text Expansion, doesn't work everywhere
* CopyQ - Clipboard manager
* Docker/Portainer 
  * Docker
    * `curl -fsSL https://get.docker.com | sh`
    * `sudo setfacl --modify user:kyeotic:rw /var/run/docker.sock`
  * Portainer
    * `docker volume create portainer_data`
    * `docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest`

# Issues

* xbox controller did not work without installing additional drivers
* autokey (AHK alternative on linux) does not work everywhere, texpander works in more places but still not all. I still dont have a good AHK replacement for either text expansion or window management
* Windows dont remember their position after restart or reboot
* I tried howdy out for camera login, but its super flaky.
* Bitwarden does not support deskptop->browser integration
* No support for iCloud Drive, limited support for Google Drive
* discord cant use xbox controller keybinds