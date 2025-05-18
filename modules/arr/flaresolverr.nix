{ config, pkgs, ... }:

{
  services.flaresolverr = {
    enable = true;
    openFirewall = true;
    port = 8191;  # Default port
  };
  
  networking.firewall.allowedTCPPorts = [ 8191 ];
}