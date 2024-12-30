{ config, pkgs, ... }:

{
  services.rss-bridge = {
    enable = true;
    virtualHost = "localhost";
    
    user = "rssbridge";
    group = "rssbridge";
    
    pool = "rss-bridge";
    
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