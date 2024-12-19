{ config, pkgs, ... }:

{
  users.users.k = {
    isNormalUser = true;
    description = "k";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };
}
