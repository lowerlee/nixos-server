{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos-server";
    networkmanager.enable = true;
    firewall = {
      checkReversePath = "loose";
      allowedTCPPorts = [ 8384 22000 8080 8999 8096 3000 8081 8082 9090 9100 3001 ];
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
