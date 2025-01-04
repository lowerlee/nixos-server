{config, pkgs, ... }:

{
  services.miniflux = {
    enable = true;
    adminCredentialsFile = "/etc/miniflux.env"
  };
}