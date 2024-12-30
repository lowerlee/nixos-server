{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/home-manager.nix
    ./modules/networking.nix
    ./modules/system.nix
    ./modules/users.nix
    ./modules/syncthing.nix
    ./modules/tailscale.nix
    ./modules/qbittorrent.nix
    ./modules/jellyfin.nix
    ./modules/rss-bridge.nix
    ./modules/freshrss.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
