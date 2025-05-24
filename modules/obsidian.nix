{ config, pkgs, ... }:

{
  # Build the image from the latest git main branch (not the old 2022 release)
  systemd.services.build-obsidian-remote = {
    description = "Build Obsidian Remote from Latest Git Main Branch";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "build-obsidian" ''
        set -e
        export PATH=${pkgs.git}/bin:${pkgs.podman}/bin:$PATH
        echo "Building obsidian-remote from latest main branch (not 2022 release)..."
        podman build \
          --tag obsidian-remote:latest-git \
          --pull=always \
          --no-cache \
          https://github.com/sytone/obsidian-remote.git#main
        echo "Build completed from latest git commits"
      '';
      User = "root";
    };
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.git pkgs.podman ];  # Ensure git and podman are available
  };

  # Ensure container service starts after build
  systemd.services.podman-obsidian-remote = {
    after = [ "build-obsidian-remote.service" ];
    requires = [ "build-obsidian-remote.service" ];
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      obsidian-remote = {
        image = "obsidian-remote:latest-git";  # Use locally built from main branch
        autoStart = true;
        ports = [ "8090:8080" ];  # Using 8090 to avoid potential conflicts
        volumes = [
          "/home/k/obsidian/vaults:/vaults:Z"
          "/home/k/obsidian/config:/config:Z"
          # Mount a custom startup script
          "${pkgs.writeText "custom-autostart" ''
            [Desktop Entry]
            Type=Application
            Name=Obsidian
            Exec=/usr/bin/obsidian --no-sandbox
            Hidden=false
            NoDisplay=false
            X-GNOME-Autostart-enabled=true
          ''}:/home/abc/.config/autostart/obsidian.desktop:Z"
        ];
        environment = {
          PUID = "1000";  # User ID for k (check with id command)
          PGID = "100";   # Group ID for users (check with id command)
          TZ = "America/Los_Angeles";
          DOCKER_MODS = "linuxserver/mods:universal-git";
          # Auto-start Obsidian
          AUTO_UPDATES = "false";
          OBSIDIAN_ARGS = "--disable-gpu";
        };
        extraOptions = [
          "--security-opt=no-new-privileges:true"
          "--shm-size=1gb"
          "--device=/dev/dri"
          "--tmpfs=/tmp:noexec,nosuid,size=1g"
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