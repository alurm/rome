{
  config,
  lib,
  ...
}: {
  # Use the recommended bootloader. (It isn't the default for compatibility.)
  boot.loader.raspberry-pi.bootloader = "kernel";

  # Swap to compressed RAM.
  zramSwap.enable = true;

  # Look for corrupted blocks monthly.
  services.btrfs.autoScrub.enable = true;

  # Skip building the NixOS manual on every rebuild.
  documentation.nixos.enable = false;

  networking.firewall = {
    # Accept Tailscale traffic unconditionally.
    trustedInterfaces = ["tailscale0"];

    # Drop traffic unless explicitly allowed on an interface.
    allowedTCPPorts = lib.mkForce [];
    allowedUDPPorts = lib.mkForce [];
    allowedTCPPortRanges = lib.mkForce [];
    allowedUDPPortRanges = lib.mkForce [];

    interfaces.end0.allowedUDPPorts = [
      # Make direct connections possible.
      config.services.tailscale.port
    ];
  };

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];

    # Perform garbage collection daily at 03:15.
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    # Deduplicate the store using hardlinks.
    optimise.automatic = true;
  };

  services = {
    syncthing = {
      enable = true;
      guiAddress = "/var/lib/syncthing/gui.sock";
    };

    tailscale = {
      enable = true;
      extraSetFlags = ["--ssh"];
      # Enable IP forwarding in order to be usable as an exit node.
      useRoutingFeatures = "server";
    };

    miniflux = {
      enable = true;
      config = {
        CREATE_ADMIN = false;
        LISTEN_ADDR = "/run/miniflux/http.sock";
      };
    };
  };
}
