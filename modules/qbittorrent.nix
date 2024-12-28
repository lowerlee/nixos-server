{ config, pkgs, ... }:

{
  services.qbittorrent = {
    enable = true;
    dataDir = "/mnt/media";
    openFirewall = true;
    port = 8999;
    webPort = 8080;
    user = "k";
    group = "users";
  };
}
