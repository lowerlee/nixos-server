{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      obsidian-remote = {
        image = "ghcr.io/sytone/obsidian-remote:latest";
        autoStart = true;
        ports = [ "8090:8080" ];  # Using 8090 to avoid potential conflicts
        volumes = [
          "/home/k/obsidian/vaults:/vaults"
          "/home/k/obsidian/config:/config"
        ];
        environment = {
          PUID = "1000";  # User ID for k (check with id command)
          PGID = "100";   # Group ID for users (check with id command)
          TZ = "America/Los_Angeles";
          DOCKER_MODS = "linuxserver/mods:universal-git";
        };
        extraOptions = [
          "--security-opt=no-new-privileges:true"
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