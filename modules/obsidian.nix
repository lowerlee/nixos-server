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
          "/home/k/obsidian/vaults:/vaults:Z"
          "/home/k/obsidian/config:/config:Z"
          "/home/k/obsidian:/workspace:Z"
        ];
        environment = {
          PUID = "1000";
          PGID = "100";
          TZ = "America/Los_Angeles";
          # Remove DOCKER_MODS if causing issues
          # DOCKER_MODS = "linuxserver/mods:universal-git";
          CUSTOM_PORT = "8080";
          CUSTOM_USER = "abc";
          PASSWORD = "";
          KEYBOARD = "en-us-qwerty";
          TITLE = "Obsidian Remote";
          # Force Obsidian to start
          ENABLE_OBSIDIAN = "true";
          OBSIDIAN_ARGS = "--disable-gpu-sandbox --no-sandbox";
        };
        extraOptions = [
          "--security-opt=no-new-privileges:true"
          "--shm-size=2gb"
          "--cap-add=SYS_ADMIN"
          "--device=/dev/dri"
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