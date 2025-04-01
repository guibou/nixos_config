This is my configuration

It is a mess because I don't really like cleaning things up.

It contains my nixos and my home manager configuration, both are split.

# How to install

- On nixos install live, clone this repo and run `sh nixos/run_disko.sh`, it will FORMAT your disk. (you may have to change a few settings here to point to the correct disk).
- Then run `nixos-install ~/path/to/this/repo`
- Move this repo to your `/home`.
- Reboot

On user, run:

- `nix run github:nix-community/home-manager# -- switch --flake ./path/to/this/repo`

# What should be done manually once system is reinstalled

- Cloning repo ;)
- vim `:PackerInstall`
- Open `firefox` and click everywhere for "first session", enable addons and
  log to useful site (in the correct workspace)
- Add credentials into `kubectl` configuration.

# Things not handled by nix

- [X] Firefox addons & settings

  - [X] bitwarden
  - [X] dictionnaries
  - [X] multi container mode
  - [X] addblocker

- My vim setup, right now, I need to manually install packer and run `:PackerInstall` in vim.

- Credentials (ssh keys, aws keys). For now I copy everything from bitwarden manually, that's a pain.

SEE: sops nix

- kubectl configuration.

# TODO

- Should I setup a cachix for my custom packages (kernel? neovim?)
- I would like a `nix run github:guibou/nixos_config#nvim` runable setup.

# Boot security warning, should I worry

- https://discourse.nixos.org/t/security-warning-when-installing-nixos-23-11/37636

# A note about safety

There is no credential in this repo (I hope so... tell me). However my system password is in the repo in a hashed form.
