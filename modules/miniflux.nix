{config, pkgs, ... }:

{
  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    
    config = {
      LISTEN_ADDR = "0.0.0.0:8082";
      BASE_URL = "http://100.69.173.61:8082";
      
      CREATE_ADMIN = "1";
      ADMIN_USERNAME = "admin";
      ADMIN_PASSWORD = "adminadmin";
      
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