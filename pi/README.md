# Pi

A NixOS configuration for a Raspberry Pi 5 booting from a BTRFS USB SSD, reachable over Tailscale.

Kudos to the [nixos-raspberrypi] project for making this easier.

## Installation steps

### Using the nixos-raspberrypi installer

The initial installer for the SD card can be found [here](https://github.com/nvmd/nixos-raspberrypi/actions).

After flashing the installer, you may want to install your keys. One way to do that is to mount the second partition of the SD card and create the /root/.ssh/authorized_keys file there with proper permissions for it and its parents (0700 for root and .ssh, 0600 for authorized_keys, all owned by root).

### Using nixos-anywhere to install the bootstrap system and enable Tailscale

The initial installer will print the IP address of the system to the display connected to the Pi. Without a display, find the IP in your router's list of connected devices.

Put your SSH public key in [specifics.nix] and use the following command to install the bootstrap system:

```shell
nix run github:nix-community/nixos-anywhere -- --flake .#bootstrap --build-on remote --no-reboot root@<ip>
```

After that, you can remove the SD card, reboot, log in with `ssh root@<ip>` and run `tailscale up` to enable Tailscale.

Note that you need to have a Tailscale policy which would enable root SSH logins for the Pi. Something like the following can work:

```hujson
{
	"tagOwners": {
		"tag:pi": ["autogroup:admin"],
	},

	"grants": [
		{"src": ["autogroup:member"], "dst": ["autogroup:self"], "ip": ["*"]},
		{"src": ["autogroup:owner"], "dst": ["tag:pi"], "ip": ["*"]},
	],

	// Define users and devices that can use Tailscale SSH.
	"ssh": [
		{
			"action": "check",
			"src":    ["autogroup:member"],
			"dst":    ["autogroup:self"],
			"users":  ["autogroup:nonroot", "root"],
		},
		{
			"action": "accept",
			"src":    ["autogroup:owner"],
			"dst":    ["tag:pi"],
			"users":  ["root"],
		},
	],
}
```

Tag the Pi as `tag:pi` and check that `ssh root@<tailscale-name>` works.

Then switch to the main configuration to disable OpenSSH (described below).

## Switching the system to a new configuration

Run `nixos-rebuild switch --flake . --{target,build}-host=<host>`.

You may wish to create a simple config at `~/.ssh/config` to log in as root by default:

```text
Host <host>
User root
```

## Available services

- **[Tailscale]**: a software-defined mesh virtual private network
- **[Syncthing]**: an encryption-friendly continuous file synchronization program
- **[TiddlyPWA]**: an offline-friendly, encrypted, synced notes app
- **[Miniflux]**: a minimalistic feed reader

[nixos-raspberrypi]: https://github.com/nvmd/nixos-raspberrypi
[specifics.nix]: ./specifics.nix
[Tailscale]: https://tailscale.com
[Syncthing]: https://syncthing.net
[TiddlyPWA]: https://tiddly.packett.cool
[Miniflux]: https://miniflux.app
