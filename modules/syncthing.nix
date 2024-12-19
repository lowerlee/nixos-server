{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;
    dataDir = "/home/k";
    user = "k";
    settings = {
      gui = {
        user = "nixos-server";
        password = "k";
      };
      devices = {
        "pixel9-pro-xl" = {
          id = "25E6N42-MJMW4G4-GYOUDGC-55GPVZK-MTFEJID-YC3QW5A-UZO7Q65-W4L23QC";
          addresses = [ "tcp://100.106.130.14:22000" "quic://100.106.130.14:22000" ];
        };
        "nixos-desktop" = {
          id = "JVJWMW6-YOQPXH2-WKQRKYN-QPFRZGX-LO52ONW-2B46SY7-JX63A6S-WNRHAQQ";
          addresses = [ "tcp://100.90.112.73:22000" "quic://100.90.112.73:22000" ];
        };  
      };
      folders = {
        "notes" = {
          path = "/home/k/obsidian";
          devices = [ "pixel9-pro-xl" "nixos-desktop" ];
        };
      };
      options = {
        localAnnounceEnabled = false;
        relaysEnabled = false;
        globalAnnounceEnabled = false;
      };
    };
  };
}
