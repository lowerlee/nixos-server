{config, pkgs, ... }:

let
  credentialsContent = ''
    ADMIN_USERNAME=k
    ADMIN_PASSWORD=k
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /var/lib/miniflux 0755 miniflux miniflux -"
    "f /var/lib/miniflux/admin-credentials 0600 miniflux miniflux - ${builtins.replaceStrings ["\n"] ["\\n"] credentialsContent}"
  ];

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = "/var/lib/miniflux/admin-credentials";
    
    config = {
      LISTEN_ADDR = "0.0.0.0:8082";
      BASE_URL = "100.69.173.61:8082";
      
      POLLING_FREQUENCY = "60";
      BATCH_SIZE = "100";
      WORKER_POOL_SIZE = "5";
      
      CLEANUP_FREQUENCY_HOURS = "24";
      CLEANUP_ARCHIVE_READ_DAYS = "60";
      CLEANUP_ARCHIVE_UNREAD_DAYS = "180";
      
      LOG_LEVEL = "info";
    };
  };
}