{ config, lib, pkgs, ... }:

{
  # Enable qBittorrent service
  services.qbittorrent = {
    enable = true;
    # Run as a specific user (you might want to create this user in users.nix)
    user = "qbittorrent";
    group = "qbittorrent";
    
    # Configure web interface
    openWebInterface = true;
    port = 8080;  # Web interface port
    
    # Data directory
    dataDir = "/var/lib/qbittorrent";
    
    # Configure settings
    openFirewall = true;  # This will open the webui port in the firewall
    
    # Additional configuration options can be set in the config file
    configDir = "/var/lib/qbittorrent/.config/qBittorrent";
  };
}
