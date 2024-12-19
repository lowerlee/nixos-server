{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos-server";
    networkmanager.enable = true;
    firewall = {
      checkReversePath = "loose";
      allowedTCPPorts = [ 8384 ];
      trustedInterfaces = [ "tailscale0" ];
      enable = true;
    };
    nftables.enable = true;
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
  };
}
