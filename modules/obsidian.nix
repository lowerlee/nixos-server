{ config, pkgs, ... }:

{
  # Main container service
  systemd.services.obsidian-remote-container = {
    description = "Obsidian Remote Container";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      Type = "exec";
      ExecStartPre = pkgs.writeShellScript "obsidian-pre" ''
        # Stop any existing container
        ${pkgs.podman}/bin/podman stop obsidian-remote 2>/dev/null || true
        ${pkgs.podman}/bin/podman rm obsidian-remote 2>/dev/null || true
      '';
      
      ExecStart = ''
        ${pkgs.podman}/bin/podman run --rm \
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
      '';
      
      ExecStop = "${pkgs.podman}/bin/podman stop obsidian-remote";
      Restart = "on-failure";
      RestartSec = "30";
    };
  };

  # Separate service to start Obsidian inside the container
  systemd.services.obsidian-remote-start = {
    description = "Start Obsidian inside container";
    after = [ "obsidian-remote-container.service" ];
    requires = [ "obsidian-remote-container.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      
      # Wait for container to be fully ready
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'sleep 30'";
      
      ExecStart = pkgs.writeShellScript "obsidian-start" ''
        # Setup autostart
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
      '';
      
      Restart = "on-failure";
      RestartSec = "10";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8090 ];

  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k users"
    "d /home/k/obsidian/vaults 0755 k users"
    "d /home/k/obsidian/config 0755 k users"
  ];
}