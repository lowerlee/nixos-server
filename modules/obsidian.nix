{ config, pkgs, ... }:

{
  # Use the OCI containers module which handles restarts better
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
          "--tmpfs=/tmp:noexec,nosuid,size=1g"
        ];
      };
    };
  };

  # Create a service that waits for the container to stabilize and then starts Obsidian
  systemd.services.obsidian-remote-init = {
    description = "Initialize Obsidian in container";
    after = [ "podman-obsidian-remote.service" ];
    requires = [ "podman-obsidian-remote.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "30";
      
      ExecStart = pkgs.writeShellScript "obsidian-init" ''
        # Wait for container to be running
        echo "Waiting for container to be ready..."
        for i in {1..60}; do
          if ${pkgs.podman}/bin/podman ps | grep -q obsidian-remote; then
            echo "Container is running"
            break
          fi
          sleep 1
        done
        
        # Wait for X server to be ready inside container
        echo "Waiting for X server..."
        for i in {1..30}; do
          if ${pkgs.podman}/bin/podman exec obsidian-remote bash -c "pgrep -x Xvfb" >/dev/null 2>&1; then
            echo "X server is ready"
            break
          fi
          sleep 2
        done
        
        # Additional wait for container to fully stabilize
        sleep 10
        
        # Setup autostart
        echo "Setting up Obsidian autostart..."
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
        
        # Check if Obsidian is already running
        if ! ${pkgs.podman}/bin/podman exec obsidian-remote pgrep -f "obsidian --no-sandbox" >/dev/null 2>&1; then
          echo "Starting Obsidian..."
          ${pkgs.podman}/bin/podman exec -d obsidian-remote bash -c "su - abc -c 'DISPLAY=:1 /usr/bin/obsidian --no-sandbox'"
        else
          echo "Obsidian is already running"
        fi
        
        # Verify Obsidian started
        sleep 5
        if ${pkgs.podman}/bin/podman exec obsidian-remote pgrep -f "obsidian --no-sandbox" >/dev/null 2>&1; then
          echo "Obsidian started successfully"
        else
          echo "Failed to start Obsidian"
          exit 1
        fi
      '';
    };
  };

  # Alternative: Add a systemd path unit to monitor and restart Obsidian if needed
  systemd.paths.obsidian-monitor = {
    description = "Monitor Obsidian container";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      # Check every 30 seconds
      PathExists = "/run/podman/podman.sock";
      Unit = "obsidian-monitor.service";
    };
  };

  systemd.services.obsidian-monitor = {
    description = "Check and restart Obsidian if needed";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "check-obsidian" ''
        # Check if container is running
        if ${pkgs.podman}/bin/podman ps | grep -q obsidian-remote; then
          # Check if Obsidian process is running
          if ! ${pkgs.podman}/bin/podman exec obsidian-remote pgrep -f "obsidian --no-sandbox" >/dev/null 2>&1; then
            echo "Obsidian not running, starting it..."
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