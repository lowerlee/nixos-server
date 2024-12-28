{ config, pkgs, ... }:

{
  systemd.services.qbittorrent = {
    enable = true;
    description = "qBittorrent-nox daemon";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      QBT_WEBUI_USERNAME = "admin";
      QBT_WEBUI_PASSWORD = "adminadmin";
    };

    serviceConfig = {
      ExecStart = ''
        ${pkgs.qbittorrent-nox}/bin/qbittorrent-nox \
        --webui-port=8080 \
        --torrenting-port=8999 \
        --save-path=/mnt/media \
      '';
      User = "k";
      Group = "users";
      Restart = "on-failure";
    };
  };
}