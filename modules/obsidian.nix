{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      obsidian-remote = {
        image = "ghcr.io/sytone/obsidian-remote:latest";
        autoStart = true;
        ports = [ "8090:8080" ];
        volumes = [
          "/home/k/obsidian:/vaults:Z"
          "/home/k/obsidian/config:/config:Z"
        ];
        environment = {
          PUID = "1000";
          PGID = "100";
          TZ = "America/Los_Angeles";
          DOCKER_MODS = "linuxserver/mods:universal-git";
          AUTO_UPDATES = "false";
          OBSIDIAN_ARGS = "--disable-gpu";
        };
        extraOptions = [
          "--security-opt=no-new-privileges:true"
          "--shm-size=1gb"
        ];
      };
    };
  };

  # Override the generated service to add our startup command
  systemd.services.podman-obsidian-remote = {
    serviceConfig.ExecStartPost = pkgs.writeShellScript "start-obsidian" ''
      # Wait for container to be ready
      sleep 40
      
      # Setup and start Obsidian
      ${pkgs.podman}/bin/podman exec obsidian-remote bash -c "
        mkdir -p /home/abc/.config/autostart/
        cat > /home/abc/.config/autostart/obsidian.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Obsidian
Exec=/usr/bin/obsidian --no-sandbox
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
        chown abc:abc /home/abc/.config/autostart/obsidian.desktop
      "
      
      ${pkgs.podman}/bin/podman exec -d obsidian-remote bash -c "su - abc -c 'DISPLAY=:1 /usr/bin/obsidian --no-sandbox'"
    '';
  };

  networking.firewall.allowedTCPPorts = [ 8090 ];

  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k users"
    "d /home/k/obsidian/vaults 0755 k users"
    "d /home/k/obsidian/config 0755 k users"
  ];
}