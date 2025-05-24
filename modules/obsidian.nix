{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      obsidian-remote = {
        # Try a specific version instead of latest
        image = "ghcr.io/sytone/obsidian-remote:version-1.5.3";
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
          # Minimal environment variables
          DISPLAY = ":99";
          RESOLUTION = "1920x1080x24";
        };
        extraOptions = [
          "--privileged"  # Sometimes needed for desktop apps
          "--shm-size=2gb"
        ];
      };
    };
  };

  # Open firewall port
  networking.firewall.allowedTCPPorts = [ 8090 ];

  # Create required directories with correct permissions
  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k users"
    "d /home/k/obsidian/vaults 0755 k users"
    "d /home/k/obsidian/config 0755 k users"
    # Create a test vault
    "f /home/k/obsidian/vaults/README.md 0644 k users - # Welcome to Obsidian!"
  ];
}