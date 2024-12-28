{ config, pkgs, ... }:

{
  systemd.services.qbittorrent = {
    description = "qBittorrent-nox service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "k";
      Group = "users";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox --webui-port=8080";
      Restart = "on-failure";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 8999 ];
  networking.firewall.allowedUDPPorts = [ 8999 ];
}