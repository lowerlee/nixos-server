{ config, pkgs, ... }:

{
  services = {
    nfs = {
      server.enable = false;
      client = {
        enable = true;
        statdPort = 4000;
        lockdPort = 4001;
      };
      settings = {
        "client.mount.nfs_version" = 4;
        "client.mount.vers" = 4;
        "client.mount.timeout" = 60;
      };
    };

    rpcbind.enable = true;
  };
}