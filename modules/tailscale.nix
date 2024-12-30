{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--exit-node=us-nyc-wg-301.mullvad.ts.net"
      "--exit-node-allow-lan-access=true"
      "--advertise-exit-node"
      "--accept-dns=false"
    ];
  };

  # Enable Funnel
  systemd.services.tailscale-funnel = {
    description = "Tailscale Funnel for RSS-Bridge";
    after = [ "network-online.target" "tailscale.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.tailscale}/bin/tailscale serve 3000";
    };
  };
}