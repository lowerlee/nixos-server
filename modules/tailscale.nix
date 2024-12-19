{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--exit-node=us-nyc-wg-301.mullvad.ts.net"
      "--exit-node-allow-lan-access=true"
    ];
  };
}
