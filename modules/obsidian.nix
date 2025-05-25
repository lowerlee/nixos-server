{ config, pkgs, ... }:

{
  systemd.services.obsidian-remote = {
    description = "Obsidian Remote Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "forking";
      ExecStart = pkgs.writeShellScript "obsidian-start" ''
        # Remove any existing container
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
          --tmpfs=/tmp:noexec,nosuid,size=1g \
          ghcr.io/sytone/obsidian-remote:latest
        
        # Wait for container to be healthy
        for i in {1..30}; do
          if ${pkgs.podman}/bin/podman exec obsidian-remote bash -c "pgrep -x Xvfb" >/dev/null 2>&1; then
            echo "Container is ready"
            break
          fi
          echo "Waiting for container to be ready... ($i/30)"
          sleep 2
        done
        
        # Setup and start Obsidian
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
        
        # Start Obsidian in background
        ${pkgs.podman}/bin/podman exec obsidian-remote bash -c "nohup su - abc -c 'DISPLAY=:1 /usr/bin/obsidian --no-sandbox' >/dev/null 2>&1 &"
        
        # Give it a moment to start
        sleep 5
      '';
      
      ExecStop = "${pkgs.podman}/bin/podman stop obsidian-remote";
      Restart = "on-failure";
      RestartSec = "30";
      TimeoutStartSec = "120";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8090 ];

  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k users"
    "d /home/k/obsidian/vaults 0755 k users"
    "d /home/k/obsidian/config 0755 k users"
  ];
}