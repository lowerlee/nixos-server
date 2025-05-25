{ config, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    
    # Recommended settings for performance and security
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    
    # Common configuration for all virtual hosts
    commonHttpConfig = ''
      # Security headers
      add_header X-Frame-Options DENY;
      add_header X-Content-Type-Options nosniff;
      add_header X-XSS-Protection "1; mode=block";
      add_header Referrer-Policy "strict-origin-when-cross-origin";
      
      # Hide nginx version
      server_tokens off;
      
      # Rate limiting
      limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
      limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
    '';

    virtualHosts = {
      # All services under one virtual host
      "100.69.173.61" = {
        default = true;
        locations = {
          # Main dashboard/landing page
          "/" = {
            return = "200 '<html><body><h1>NixOS Server</h1><ul><li><a href=\"/syncthing\">Syncthing</a></li><li><a href=\"/qbittorrent\">qBittorrent</a></li><li><a href=\"/jellyfin\">Jellyfin</a></li><li><a href=\"/sonarr\">Sonarr</a></li><li><a href=\"/radarr\">Radarr</a></li><li><a href=\"/prowlarr\">Prowlarr</a></li><li><a href=\"/grafana\">Grafana</a></li></ul></body></html>'";
            extraConfig = ''
              add_header Content-Type text/html;
            '';
          };

          # Syncthing
          "/syncthing/" = {
            proxyPass = "http://127.0.0.1:8384/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              
              # WebSocket support for Syncthing
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            '';
          };

          # qBittorrent
          "/qbittorrent/" = {
            proxyPass = "http://127.0.0.1:8080/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              
              # Handle qBittorrent's authentication
              proxy_cookie_path / /qbittorrent/;
              
              # Rate limiting for login attempts
              limit_req zone=login burst=5 nodelay;
            '';
          };

          # Jellyfin
          "/jellyfin/" = {
            proxyPass = "http://127.0.0.1:8096/jellyfin/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              
              # WebSocket support for Jellyfin
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
              
              # Jellyfin specific headers
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Server $host;
              
              # Large file uploads for media
              client_max_body_size 20G;
            '';
          };

          # Sonarr
          "/sonarr/" = {
            proxyPass = "http://127.0.0.1:8989/sonarr/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              
              # API rate limiting
              limit_req zone=api burst=20 nodelay;
            '';
          };

          # Radarr
          "/radarr/" = {
            proxyPass = "http://127.0.0.1:7878/radarr/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              
              # API rate limiting
              limit_req zone=api burst=20 nodelay;
            '';
          };

          # Prowlarr
          "/prowlarr/" = {
            proxyPass = "http://127.0.0.1:9696/prowlarr/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };

          # Grafana (from your monitor.nix)
          "/grafana/" = {
            proxyPass = "http://127.0.0.1:3001/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              
              # WebSocket support for Grafana
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            '';
          };

          # Prometheus (optional - be careful with security)
          "/prometheus/" = {
            proxyPass = "http://127.0.0.1:9090/prometheus/";
            extraConfig = ''
              # Restrict access to Prometheus
              allow 192.168.0.0/16;
              allow 10.0.0.0/8;
              allow 172.16.0.0/12;
              allow 100.0.0.0/10;  # Tailscale
              deny all;
              
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };

          # FreshRSS (if you enable it)
          "/freshrss/" = {
            proxyPass = "http://127.0.0.1:8081/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };

          # Miniflux (if you enable it)
          "/miniflux/" = {
            proxyPass = "http://127.0.0.1:8082/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
          };

          # Obsidian Remote (if you use the obsidian.nix)
          "/obsidian/" = {
            proxyPass = "http://127.0.0.1:8090/";
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              
              # WebSocket and VNC support
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
              
              # Increase timeouts for VNC
              proxy_read_timeout 3600s;
              proxy_send_timeout 3600s;
            '';
          };
        };
      };
    };
  };

  # Open HTTP and HTTPS ports
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Optional: Create basic auth file for sensitive services
  # Uncomment and customize as needed
  # environment.etc."nginx/htpasswd".text = ''
  #   admin:$2b$10$example_hash_here
  # '';
}