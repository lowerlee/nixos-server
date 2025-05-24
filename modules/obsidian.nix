{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      obsidian-remote = {
        image = "ghcr.io/sytone/obsidian-remote:1.5.3";
        autoStart = true;
        ports = [ "8090:8080" ];
        volumes = [
          "/home/k/obsidian/vaults:/vaults:Z"
          "/home/k/obsidian/config:/config:Z"
        ];
        environment = {
          PUID = "1000";
          PGID = "100";
          TZ = "America/Los_Angeles";
        };
        extraOptions = [
          "--security-opt=no-new-privileges:true"
          "--shm-size=1gb"
        ];
      };
    };
  };

  # Open firewall port
  networking.firewall.allowedTCPPorts = [ 8090 ];

  # Create required directories
  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k users"
    "d /home/k/obsidian/vaults 0755 k users"
    "d /home/k/obsidian/config 0755 k users"
  ];
}