{config, pkgs, ... }:

let
  # Create the credentials file using writeText
  adminCredsFile = pkgs.writeText "miniflux-admin-credentials" ''
    ADMIN_USERNAME="k"
    ADMIN_PASSWORD="14755612"
  '';
in
{
  # Copy the credentials file to /etc/miniflux during system activation
  system.activationScripts.minifluxCredentials = ''
    mkdir -p /etc/miniflux
    cp ${adminCredsFile} /etc/miniflux/admin-credentials
    chmod 600 /etc/miniflux/admin-credentials
  '';

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    
    # Reference the credentials file
    adminCredentialsFile = "/etc/miniflux/admin-credentials";
    
    config = {
      LISTEN_ADDR = "0.0.0.0:8082";
      BASE_URL = "http://100.69.173.61:8082";
      CREATE_ADMIN = 1;
      
      # Polling configuration
      POLLING_FREQUENCY = "60";
      BATCH_SIZE = "100";
      WORKER_POOL_SIZE = "5";
      
      # Cleanup configuration
      CLEANUP_FREQUENCY_HOURS = "24";
      CLEANUP_ARCHIVE_READ_DAYS = "60";
      CLEANUP_ARCHIVE_UNREAD_DAYS = "180";
      
      # Logging
      LOG_LEVEL = "info";
    };
  };
}