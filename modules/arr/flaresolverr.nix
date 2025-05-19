{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        autoStart = true;
        ports = [ "8191:8191" ];
        environment = {
          LOG_LEVEL = "info";
          CAPTCHA_SOLVER = "none";
          TZ = "America/Los_Angeles";
        };
        extraOptions = [
          "--security-opt=no-new-privileges:true"
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8191 ];
}