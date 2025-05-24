{ config, pkgs, ... }:

{
  # Create necessary directories
  systemd.tmpfiles.rules = [
    "d /var/lib/obsidian-remote 0755 k users"
    "d /var/lib/obsidian-remote/config 0755 k users"
  ];

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      obsidian-remote = {
        image = "ghcr.io/sytone/obsidian-remote:latest";
        autoStart = true;
        ports = [ 
          "8080:8080"
          "8443:8443" 
        ];
        volumes = [
          # Use your existing Syncthing obsidian folder as the vault
          "/home/k/obsidian:/vaults:Z"
          "/var/lib/obsidian-remote/config:/config:Z"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "America/Los_Angeles";
          DOCKER_MODS = "linuxserver/mods:universal-git";
          CUSTOM_PORT = "8080";
          CUSTOM_HTTPS_PORT = "8443";
          # Optional: Set username/password for authentication
          # CUSTOM_USER = "your_username";
          # PASSWORD = "your_password";
        };
        extraOptions = [
          "--security-opt=no-new-privileges:true"
        ];
      };
    };
  };

  # Open firewall ports
  networking.firewall.allowedTCPPorts = [ 8080 8443 ];
}