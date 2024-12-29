{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    user = "k";
    group = "users";
    openFirewall = true;
  };
}