{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--exit-node=us-phx-wg-103.mullvad.ts.net"
      "--exit-node-allow-lan-access=true"
    ];
  };
}
