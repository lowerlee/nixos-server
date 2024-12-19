{ config, pkgs, ... }:

{
  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8384 ];
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
  };
}
