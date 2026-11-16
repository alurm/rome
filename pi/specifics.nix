# Configuration specific to my setup.
{
  config,
  lib,
  ...
}: {
  options.tiddlypwa.url = lib.mkOption {type = lib.types.str;};

  config = {
    time.timeZone = "Asia/Tbilisi";
    networking.hostName = "pi";
    system.stateVersion = "26.05";

    users.users.root.openssh.authorizedKeys.keys = lib.mkIf config.pi.bootstrap [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTa5MTL2Olu9Tcm9JoWfl7PoTmzHNSzXuGEl9gtzl8r alurm@mac"
    ];

    systemd.services.tiddlypwa.environment = {
      ADMIN_PASSWORD_HASH = "4KOo2AZhFdRK11qOmnGS7OK0-OQFa8YjJCVtYqUUxxY";
      ADMIN_PASSWORD_SALT = "dCfMC9_5uBFW05kbcJhkJSs0UFpSnrQoSnkTc1Uuhh4";
    };

    tiddlypwa.url = "https://tiddlypwa.snakebird-roach.ts.net/uEHetMwBRLwVsGlC4V2a1/app.html";
  };
}
