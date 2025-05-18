{ config, pkgs, ... }:

{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    user = "k";
    group = "users";
  };
}