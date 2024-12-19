{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    permitCertUid = "k";
    extraUpFlags = [
      "--reset"
      "--exit-node=us-nyc-wg-301.mullvad.ts.net"
      "--exit-node-allow-lan-access=true"
      "--accept-routes=true"
    ];
  };
}
