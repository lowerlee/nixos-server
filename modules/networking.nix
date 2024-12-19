{ config, pkgs, ... }:

{
  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8384 ];
  };
}
