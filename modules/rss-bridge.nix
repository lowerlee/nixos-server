{ config, pkgs, ... }:

{
  services.rss-bridge = {
    enable = true;
    virtualHost = "localhost";
    
    user = "rssbridge";
    group = "rssbridge";
    
    pool = {
      settings = {
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 4;
      };
    };
    
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
}