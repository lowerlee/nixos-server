{config, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker.enable = true;

  # Create the config directory
  systemd.tmpfiles.rules = [
    "d /etc/rss-bridge/config 0755 root root"
  ];

  # RSS-Bridge service
  systemd.services.rss-bridge = {
    enable = true;
    description = "RSS-Bridge Docker Service";
    wantedBy = [ "multi-user.target" ];
    requires = [ "docker.service" ];
    after = [ "docker.service" ];

    # Ensure the container is removed before starting
    preStart = ''
      ${pkgs.docker}/bin/docker rm -f rss-bridge || true
    '';

    # Main service
    script = ''
      # Build the image if it doesn't exist
      if ! ${pkgs.docker}/bin/docker image inspect rss-bridge >/dev/null 2>&1; then
        ${pkgs.docker}/bin/docker build -t rss-bridge github:RSS-Bridge/rss-bridge
      fi

      # Create and start the container
      ${pkgs.docker}/bin/docker run \
        --name rss-bridge \
        --publish 3000:80 \
        --volume /etc/rss-bridge/config:/config \
        --restart unless-stopped \
        rss-bridge
    '';

    # Cleanup on stop
    postStop = ''
      ${pkgs.docker}/bin/docker rm -f rss-bridge || true
    '';

    # Service configuration
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "10";
    };
  };

  # Add port to firewall
  networking.firewall.allowedTCPPorts = [ 3000 ];
}