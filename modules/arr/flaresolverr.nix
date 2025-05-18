{ config, pkgs, ... }:

{
  services.flaresolverr = {
    enable = true;
    openFirewall = true;
    port = 8191;
  };
  
  networking.firewall.allowedTCPPorts = [ 8191 ];
}