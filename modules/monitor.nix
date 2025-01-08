{config, pkgs, ... }:

{
  services = {
    prometheus = {
      enable = true;
      port = 9090;
      
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "systemd"
            "cpufreq"  # Changed from "cpu"
            "diskstats"
            "filesystem"
            "loadavg"
            "meminfo"
            "netdev"
            "thermal_zone"  # Changed from "temperature"
          ];
          port = 9100;
          openFirewall = true;
        };
      };

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [ "localhost:9100" ];
          }];
        }
        {
          job_name = "qbittorrent";
          static_configs = [{
            targets = [ "localhost:8080" ];
          }];
        }
        {
          job_name = "jellyfin";
          static_configs = [{
            targets = [ "localhost:8096" ];
          }];
        }
      ];
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_port = 3001;
          domain = "100.69.173.61";
          root_url = "http://100.69.173.61:3001";
          http_addr = "100.69.173.61";
        };
        security = {
          allow_embedding = true;
          cookie_secure = false;
        };
      };
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
            isDefault = true;
          }
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 9090 9100 3001 ];
}