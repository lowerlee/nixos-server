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
    ./modules/docker.nix
    ./modules/miniflux.nix
    ./modules/monitor.nix
    ./modules/arr/sonarr.nix
    ./modules/arr/radarr.nix
    ./modules/arr/prowlarr.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-runtime-6.0.36"
    "dotnet-runtime-wrapped-6.0.36"
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];

  system.stateVersion = "24.11";
}