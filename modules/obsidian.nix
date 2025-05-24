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

  # Create custom startup script
  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k users"
    "d /home/k/obsidian/vaults 0755 k users"
    "d /home/k/obsidian/config 0755 k users"
    # Create custom startup script
    "d /home/k/obsidian/scripts 0755 k users"
  ];

  environment.etc."obsidian-startup.sh" = {
    text = ''
      #!/bin/bash
      # Custom startup script for Obsidian
      export DISPLAY=:1
      sleep 5  # Wait for desktop to load
      /usr/bin/obsidian --no-sandbox &
    '';
    mode = "0755";
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      obsidian-remote = {
        image = "obsidian-remote:latest-git";
        autoStart = true;
        ports = [ "8090:8080" ];
        volumes = [
          "/home/k/obsidian/vaults:/vaults:Z"
          "/home/k/obsidian/config:/config:Z"
          "/etc/obsidian-startup.sh:/usr/local/bin/obsidian-startup.sh:Z"
        ];
        environment = {
          PUID = "1000";
          PGID = "100";
          TZ = "America/Los_Angeles";
          DOCKER_MODS = "linuxserver/mods:universal-git";
          AUTO_UPDATES = "false";
          OBSIDIAN_ARGS = "--disable-gpu";
          # Override the startup command
          CUSTOM_USER = "abc";
          AUTOSTART = "true";
        };
        extraOptions = [
          "--security-opt=no-new-privileges:true"
          "--shm-size=1gb"
          "--device=/dev/dri"
          "--tmpfs=/tmp:noexec,nosuid,size=1g"
        ];
        # Override the default command
        cmd = [ "/bin/bash", "-c", "sleep 10 && /usr/local/bin/obsidian-startup.sh && exec /usr/local/bin/dockerd-entrypoint.sh" ];
      };
    };
  };

  # Open firewall port
  networking.firewall.allowedTCPPorts = [ 8090 ];
}