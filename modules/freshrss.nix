{config, pkgs, ...}:

{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers.containers.freshrss = {
    image = "freshrss/freshrss:latest";
    autoStart = true;
    ports = ["8081:80"];
    environment = {
      TZ = "UTC";
      CRON_MIN = "1,31";
    };
    volumes = [
      "freshrss_data:/var/www/FreshRSS/data"
      "freshrss_extensions:/var/www/FreshRSS/extensions"
    ];
  };
}