{ config, pkgs, ... }:

{
  services.radarr = {
    enable = true;
    openFirewall = true;
    user = "k";
    group = "users";
    dataDir = "/var/lib/radarr";
  };
}