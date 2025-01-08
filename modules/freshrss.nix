{config, pkgs, ... }:

{
  systemd.services.freshrss = {
    enable = true;
    description = "FreshRSS Docker Service";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];

    preStart = ''
      ${pkgs.docker}/bin/docker rm -f freshrss || true
    '';

    script = ''
      exec ${pkgs.docker}/bin/docker run \
        -d \
        --restart unless-stopped \
        -p 8081:80 \
        -e TZ=Europe/Paris \
        -e 'CRON_MIN=1,31' \
        -v freshrss_data:/var/www/FreshRSS/data \
        -v freshrss_extensions:/var/www/FreshRSS/extensions \
        --name freshrss \
        freshrss/freshrss
    '';

    postStop = ''
      ${pkgs.docker}/bin/docker rm -f freshrss || true
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.docker}/bin/docker stop freshrss";
    };
  };
}