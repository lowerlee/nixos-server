{ config, pkgs, ... }:

{
  # Your existing configuration
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      obsidian-remote = {
        image = "ghcr.io/sytone/obsidian-remote:latest";
        autoStart = true;
        ports = [ "8090:8080" ];
        volumes = [
          "/home/k/obsidian/vaults:/vaults"
          "/home/k/obsidian/config:/config"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "America/Los_Angeles";
        };
      };
    };
  };

  # Override the systemd service to add security options
  systemd.services.podman-obsidian-remote = {
    serviceConfig = {
      ExecStart = lib.mkForce [
        ""  # Clear the existing ExecStart
        "${config.virtualisation.podman.package}/bin/podman run --rm --name=obsidian-remote --security-opt seccomp=unconfined --log-driver=journald --cidfile=/run/podman-obsidian-remote.ctr-id --cgroups=no-conmon --sdnotify=conmon -d --replace -p 8090:8080 -v /home/k/obsidian/vaults:/vaults:rw -v /home/k/obsidian/config:/config:rw -e PUID=1000 -e PGID=1000 -e TZ=America/Los_Angeles ghcr.io/sytone/obsidian-remote:latest"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8090 ];

  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k k"
    "d /home/k/obsidian/vaults 0755 k k"
    "d /home/k/obsidian/config 0755 k k"
  ];
}