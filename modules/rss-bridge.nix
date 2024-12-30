{config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /etc/rss-bridge/config 0755 root root"
  ];

  systemd.services.rss-bridge = {
    enable = true;
    description = "RSS-Bridge Docker Service";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" "network.target" ];

    preStart = ''
      ${pkgs.docker}/bin/docker rm -f rss-bridge || true
    '';

    script = ''
      if ! ${pkgs.docker}/bin/docker image inspect rss-bridge >/dev/null 2>&1; then
        ${pkgs.docker}/bin/docker build -t rss-bridge https://github.com/RSS-Bridge/rss-bridge.git#master
      fi

      exec ${pkgs.docker}/bin/docker run \
        --rm \
        --name rss-bridge \
        --publish 3000:80 \
        --volume /etc/rss-bridge/config:/config:Z \
        rss-bridge
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