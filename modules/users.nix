{ config, pkgs, ... }:

{
  users.users.k = {
    isNormalUser = true;
    description = "k";
    extraGroups = [ "networkmanager" "wheel" "podman" ];
    packages = with pkgs; [];
  };
}
