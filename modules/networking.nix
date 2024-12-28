{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos-server";
    networkmanager.enable = true;
    networkmanager.wait-online.enable = false;
    firewall = {
      checkReversePath = "loose";
      allowedTCPPorts = [ 8384 22000 ];
      allowedUDPPorts = [ 22000 21027 ];
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
