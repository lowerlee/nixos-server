{config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /etc/rss-bridge/config 0755 root root"
    "d /var/lib/rss-bridge 0755 root root"  # Directory for build context
  ];

  systemd.services.rss-bridge = {
    enable = true;
    description = "RSS-Bridge Docker Service";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" "network.target" ];

    preStart = ''
      # Clone/update the repository
      if [ ! -d /var/lib/rss-bridge/src ]; then
        ${pkgs.git}/bin/git clone https://github.com/lowerlee/rss-bridge.git /var/lib/rss-bridge/src
      else
        cd /var/lib/rss-bridge/src && ${pkgs.git}/bin/git pull
      fi

      # Always rebuild the image with latest code
      ${pkgs.docker}/bin/docker build -t rss-bridge:latest /var/lib/rss-bridge/src
      ${pkgs.docker}/bin/docker rm -f rss-bridge || true
    '';

    script = ''
      exec ${pkgs.docker}/bin/docker run \
        --rm \
        --name rss-bridge \
        --publish 3000:80 \
        --volume /etc/rss-bridge/config:/config:Z \
        rss-bridge:latest
    '';

    postStop = ''
      ${pkgs.docker}/bin/docker rm -f rss-bridge || true
    '';

    serviceConfig = {
      Type = "exec";
      ExecStop = "${pkgs.docker}/bin/docker stop rss-bridge";
      Restart = "always";
      RestartSec = "10";
      StartLimitIntervalSec = "60";
      StartLimitBurst = "3";
    };
  };
}