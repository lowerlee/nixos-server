{ config, pkgs, ... }:

{
  systemd.services.qbittorrent = {
    enable = true;
    description = "qBittorrent-nox daemon";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.qbittorrent-nox}/bin/qbittorrent-nox \
        --webui-port=8080 \
        --torrenting-port=8999 \
        --save-path=/mnt/media \
        --daemon
      '';
      User = "k";
      Group = "users";
      Restart = "on-failure";
    };
  };
}