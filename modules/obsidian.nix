{ config, pkgs, ... }:

{
  # Nginx reverse proxy for subpath support
  services.nginx = {
    enable = true;
    virtualHosts."localhost" = {
      listen = [{
        addr = "127.0.0.1";
        port = 8092;
      }];
      
      locations."/" = {
        return = "301 /obsidian/";
      };
      
      locations."/obsidian" = {
        return = "301 /obsidian/";
      };
      
      locations."/obsidian/" = {
        proxyPass = "http://localhost:8090/";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;
          
          # WebSocket support for real-time features
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          
          # Increase timeouts for long-running operations
          proxy_read_timeout 86400;
          proxy_send_timeout 86400;
          
          # Rewrite response content to fix paths
          sub_filter_types text/html text/css text/javascript application/javascript application/json;
          sub_filter 'href="/' 'href="/obsidian/';
          sub_filter 'src="/' 'src="/obsidian/';
          sub_filter 'url(/' 'url(/obsidian/';
          sub_filter 'action="/' 'action="/obsidian/';
          sub_filter '/api/' '/obsidian/api/';
          sub_filter '/static/' '/obsidian/static/';
          sub_filter_once off;
        '';
      };
      
      # Handle any API or static paths that might be accessed directly
      locations."~ ^/obsidian/(api|static|css|js|img|fonts|media)/" = {
        proxyPass = "http://localhost:8090";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          
          # Strip the /obsidian prefix when proxying
          rewrite ^/obsidian/(.*)$ /$1 break;
        '';
      };
    };
  };

  # Original Obsidian Remote service configuration
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
        
        # Wait for container to be ready
        sleep 15
        
        # Fix Obsidian startup
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
          su - abc -c 'DISPLAY=:1 /usr/bin/obsidian --no-sandbox' &
        "
        
        echo "Obsidian Remote is ready at http://localhost:8090"
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop obsidian-remote";
      Restart = "on-failure";
      RestartSec = "30";
    };
  };

  # Open firewall ports for both direct access and nginx proxy
  networking.firewall.allowedTCPPorts = [ 8090 8092 ];

  # Create required directories
  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k users"
    "d /home/k/obsidian/vaults 0755 k users"
    "d /home/k/obsidian/config 0755 k users"
  ];
}