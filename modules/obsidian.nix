{ config, pkgs, ... }:

{
  # Single service that handles everything
  systemd.services.obsidian-remote-complete = {
    description = "Complete Obsidian Remote Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "forking";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "obsidian-complete" ''
        set -e
        
        # Ensure image exists
        if ! ${pkgs.podman}/bin/podman images | grep -q "obsidian-remote.*latest-git"; then
          echo "Building obsidian-remote image..."
          ${pkgs.podman}/bin/podman build -t obsidian-remote:latest-git https://github.com/sytone/obsidian-remote.git#main
        fi
        
        # Stop any existing container
        ${pkgs.podman}/bin/podman stop obsidian-remote 2>/dev/null || true
        ${pkgs.podman}/bin/podman rm obsidian-remote 2>/dev/null || true
        
        # Start container
        ${pkgs.podman}/bin/podman run -d \
          --name obsidian-remote \
          -p 8090:8080 \
          -v /home/k/obsidian:/vaults:Z \
          -v /home/k/obsidian/config:/config:Z \
          -e PUID=1000 \
          -e PGID=100 \
          -e TZ=America/Los_Angeles \
          -e DOCKER_MODS=linuxserver/mods:universal-git \
          -e AUTO_UPDATES=false \
          -e OBSIDIAN_ARGS=--disable-gpu \
          --security-opt=no-new-privileges:true \
          --shm-size=1gb \
          --device=/dev/dri \
          --tmpfs=/tmp:noexec,nosuid,size=1g \
          obsidian-remote:latest-git
        
        echo "Container started, waiting for desktop environment..."
        
        # Wait longer for desktop to be fully ready
        for i in {1..40}; do
          if ${pkgs.podman}/bin/podman exec obsidian-remote pgrep openbox > /dev/null 2>&1; then
            echo "Desktop environment ready after $i attempts"
            break
          fi
          echo "Waiting for desktop... ($i/40)"
          sleep 2
        done
        
        # Additional wait for stability
        sleep 10
        
        echo "Setting up and starting Obsidian..."
        ${pkgs.podman}/bin/podman exec obsidian-remote bash -c "
          # Create autostart directory
          mkdir -p /home/abc/.config/autostart/
          
          # Create autostart file
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
          
          # Kill any existing obsidian processes
          pkill -f obsidian || true
          
          # Set up proper environment and start Obsidian
          export DISPLAY=:1
          export HOME=/home/abc
          
          # Start obsidian as abc user with proper environment
          nohup su - abc -c 'export DISPLAY=:1; /usr/bin/obsidian --no-sandbox' > /tmp/obsidian.log 2>&1 &
          
          # Wait a moment and check if it started
          sleep 5
          
          if pgrep -f obsidian > /dev/null; then
            echo 'Obsidian started successfully'
          else
            echo 'Obsidian failed to start, trying alternative method...'
            # Try starting with different parameters
            nohup su - abc -c 'export DISPLAY=:1; /usr/bin/obsidian --disable-gpu --no-sandbox --disable-dev-shm-usage' > /tmp/obsidian2.log 2>&1 &
            sleep 5
            if pgrep -f obsidian > /dev/null; then
              echo 'Obsidian started with alternative parameters'
            else
              echo 'Obsidian still failed to start, check logs in container'
              cat /tmp/obsidian.log || true
              cat /tmp/obsidian2.log || true
            fi
          fi
        "
        
        echo "Obsidian Remote setup completed - check http://localhost:8090"
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop obsidian-remote";
      Restart = "on-failure";
      RestartSec = "30";
    };
  };

  # Open firewall port
  networking.firewall.allowedTCPPorts = [ 8090 ];

  # Create required directories
  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k users"
    "d /home/k/obsidian/config 0755 k users"
  ];
}