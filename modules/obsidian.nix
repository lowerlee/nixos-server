{ config, pkgs, ... }:

{
  # Basic container setup
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      obsidian-remote = {
        image = "ghcr.io/sytone/obsidian-remote:latest";
        autoStart = true;
        ports = [ "8090:8080" ];
        volumes = [
          "/home/k/obsidian:/vaults:Z"
          "/home/k/obsidian/config:/config:Z"
        ];
        environment = {
          PUID = "1000";
          PGID = "100";
          TZ = "America/Los_Angeles";
          DOCKER_MODS = "linuxserver/mods:universal-git";
          AUTO_UPDATES = "false";
          OBSIDIAN_ARGS = "--disable-gpu";
        };
        extraOptions = [
          "--security-opt=no-new-privileges:true"
          "--shm-size=1gb"
        ];
      };
    };
  };

  # Timer to check and start Obsidian every minute
  systemd.timers.obsidian-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1min";
      Unit = "obsidian-check.service";
    };
  };

  systemd.services.obsidian-check = {
    description = "Check and start Obsidian if needed";
    after = [ "podman-obsidian-remote.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "check-obsidian" ''
        # Check if container is running
        if ${pkgs.podman}/bin/podman ps | grep -q obsidian-remote; then
          # Check if Obsidian process is running
          if ! ${pkgs.podman}/bin/podman exec obsidian-remote pgrep -f "obsidian --no-sandbox" >/dev/null 2>&1; then
            echo "Starting Obsidian..."
            
            # Setup autostart first
            ${pkgs.podman}/bin/podman exec obsidian-remote bash -c "
              mkdir -p /home/abc/.config/autostart/
              cat > /home/abc/.config/autostart/obsidian.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Obsidian
Exec=/usr/bin/obsidian --no-sandbox
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
              chown abc:abc /home/abc/.config/autostart/obsidian.desktop
            "
            
            # Start Obsidian
            ${pkgs.podman}/bin/podman exec -d obsidian-remote bash -c "su - abc -c 'DISPLAY=:1 /usr/bin/obsidian --no-sandbox'"
          fi
        fi
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 8090 ];

  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k users"
    "d /home/k/obsidian/vaults 0755 k users"
    "d /home/k/obsidian/config 0755 k users"
  ];
}