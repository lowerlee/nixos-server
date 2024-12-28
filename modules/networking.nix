{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos-server";
    networkmanager.enable = true;
    firewall = {
      checkReversePath = "loose";
      allowedTCPPorts = [ 8384 22000 8080 8999 ];
      allowedUDPPorts = [ 22000 21027 8999 ];
      trustedInterfaces = [ "tailscale0" ];
      enable = true;
    };
    nftables.enable = true;
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
  };

  systemd.network.wait-online.enable = false;
}
