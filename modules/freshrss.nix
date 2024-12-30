{config, pkgs, ... }:

{
  systemd.services.freshrss = {
    enable = true;
    description = "FreshRSS Docker Service";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];

    script = ''
      exec ${pkgs.docker}/bin/docker run \
        -d \
        --restart unless-stopped \
        --log-opt max-size=10m \
        -p 8081:80 \
        -e TZ=Europe/Paris \
        -e 'CRON_MIN=1,31' \
        -v freshrss_data:/var/www/FreshRSS/data \
        -v freshrss_extensions:/var/www/FreshRSS/extensions \
        --name freshrss \
        freshrss/freshrss
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.docker}/bin/docker stop freshrss";
    };
  };
}