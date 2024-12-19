{ config, pkgs, ... }:

{
  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;
}
