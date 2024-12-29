{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    user = "k";
    group = "users";
    openFirewall = true;
  };

  systemd.services.jellyfin = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}