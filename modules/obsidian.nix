{ config, pkgs, ... }:

{
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 524288;

  # Custom systemd service instead of oci-containers
  systemd.services.obsidian-remote = {
    description = "Obsidian Remote Container";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStartPre = [
        "${pkgs.podman}/bin/podman stop obsidian-remote || true"
        "${pkgs.podman}/bin/podman rm obsidian-remote || true"
      ];
      ExecStart = "${pkgs.podman}/bin/podman run --name obsidian-remote --security-opt seccomp=unconfined -p 8090:8080 -v /home/k/obsidian/vaults:/vaults:rw -v /home/k/obsidian/config:/config:rw -e PUID=1000 -e PGID=1000 -e TZ=America/Los_Angeles ghcr.io/sytone/obsidian-remote:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop obsidian-remote";
      ExecStopPost = "${pkgs.podman}/bin/podman rm obsidian-remote || true";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8090 ];

  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k k"
    "d /home/k/obsidian/vaults 0755 k k"
    "d /home/k/obsidian/config 0755 k k"
  ];
}