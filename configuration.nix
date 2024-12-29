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
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
