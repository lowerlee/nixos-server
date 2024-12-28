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
      ExecStart = ''
        ${pkgs.qbittorrent-nox}/bin/qbittorrent-nox \
          --webui-port=8080 \
          --username=admin \
          --password=Xfy@R!CKqx9qFTiAZh4%QC#bK64uXe%2Le*m
      '';
      Restart = "on-failure";
    };
  };
}