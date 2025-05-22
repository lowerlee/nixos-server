{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      obsidian-remote = {
        image = "ghcr.io/sytone/obsidian-remote:latest";
        autoStart = true;
        ports = [ "8090:8080" ];
        volumes = [
          "/home/k/obsidian/vaults:/vaults"
          "/home/k/obsidian/config:/config"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";  # Changed from 100 to 1000
          TZ = "America/Los_Angeles";
        };
      };
    };
  };

  # Open firewall port
  networking.firewall.allowedTCPPorts = [ 8090 ];

  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k k"        # Changed last 'users' to 'k'
    "d /home/k/obsidian/vaults 0755 k k"
    "d /home/k/obsidian/config 0755 k k"
  ];
}