# Module to conditionally enable configuration for bootstrapping.
# Bootstrapping enables OpenSSH, which allows running tailscale up on the new system.
# Later, OpenSSH is disabled and Tailscale is used instead to reach the system.
{
  config,
  lib,
  ...
}: {
  options.pi.bootstrap = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.pi.bootstrap {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    networking.firewall.interfaces.end0.allowedTCPPorts = [22];
  };
}
