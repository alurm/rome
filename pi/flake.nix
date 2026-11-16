{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # nixpkgs isn't used as an input override here to avoid recompiling the kernel.
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tiddlypwa = {
      flake = false;
      url = "git+https://codeberg.org/valpackett/tiddlypwa?ref=release";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-raspberrypi,
    disko,
    tiddlypwa,
  }: {
    nixosConfigurations = {
      bootstrap = self.nixosConfigurations.pi.extendModules {
        modules = [{pi.bootstrap = true;}];
      };

      pi = nixos-raspberrypi.lib.nixosSystem {
        inherit nixpkgs;
        modules = [
          nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          disko.nixosModules.disko
          ./disk.nix
          ./configuration.nix
          ./specifics.nix
          ./bootstrap.nix
          (import ./tiddlypwa.nix tiddlypwa)
        ];
      };
    };
  };
}
