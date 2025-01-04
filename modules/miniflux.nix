{config, pkgs, ... }:

{
  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;

    config = {
      LISTEN_ADDR = "0.0.0.0:8082";
      BASE_URL = "http://100.69.173.61:8082";
      CREATE_ADMIN = "0";
    };
  };
}