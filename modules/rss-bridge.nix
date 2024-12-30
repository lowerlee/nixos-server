{ config, pkgs, ... }:

{
  # Create the user and group
  users.users.rssbridge = {
    group = "rssbridge";
    isSystemUser = true;
  };

  users.groups.rssbridge = {};

  services.rss-bridge = {
    enable = true;
    virtualHost = "localhost";
    
    user = "rssbridge";  # Must match the user we created
    group = "rssbridge"; # Must match the group we created
    
    # Remove the pool setting to let it use defaults
    # pool = "rss-bridge"; 
    
    dataDir = "/var/lib/rss-bridge";
    
    config = {
      system = {
        enabled_bridges = [
          "YouTube"
        ];
      };
      
      FileCache = {
        path = "/var/cache/rss-bridge";
      };
    };
  };

  # Make sure nginx is enabled
  # services.nginx.enable = true;
}