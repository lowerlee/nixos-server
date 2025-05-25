{ config, pkgs, ... }:

let
  obsidianEntrypoint = pkgs.writeScript "obsidian-entrypoint.sh" ''
    #!/bin/bash
    
    # Start the default entrypoint in background
    /init &
    INIT_PID=$!
    
    # Wait for X server
    echo "Waiting for X server..."
    while ! pgrep -x Xvfb >/dev/null 2>&1; do
      sleep 2
    done
    
    # Wait a bit more for full initialization
    sleep 10
    
    # Setup autostart
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
    
    # Start Obsidian
    su - abc -c 'DISPLAY=:1 /usr/bin/obsidian --no-sandbox' &
    
    # Wait for the init process
    wait $INIT_PID
  '';
in
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
          "${obsidianEntrypoint}:/custom-entrypoint.sh:ro"
        ];
        environment = {
          PUID = "1000";
          PGID = "100";
          TZ = "America/Los_Angeles";
          DOCKER_MODS = "linuxserver/mods:universal-git";
          AUTO_UPDATES = "false";
          OBSIDIAN_ARGS = "--disable-gpu";
        };
        entrypoint = "/custom-entrypoint.sh";
        extraOptions = [
          "--security-opt=no-new-privileges:true"
          "--shm-size=1gb"
          "--tmpfs=/tmp:noexec,nosuid,size=1g"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8090 ];

  systemd.tmpfiles.rules = [
    "d /home/k/obsidian 0755 k users"
    "d /home/k/obsidian/vaults 0755 k users"
    "d /home/k/obsidian/config 0755 k users"
  ];
}