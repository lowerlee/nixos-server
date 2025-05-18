{ config, pkgs, ... }:

{
  services.sonarr = {
    enable = true;
    openFirewall = true;
    user = "k";
    group = "users";
    dataDir = "/var/lib/sonarr";
  };
}