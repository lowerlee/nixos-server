{ config, pkgs, ... }:

{
  home-manager.users.k = { pkgs, ... }: {  
    home.stateVersion = "24.11";           

    home.packages = with pkgs; [
      git
    ];

    programs = {
      git = {
        enable = true;
        userName = "lowerlee";
        userEmail = "minleekevin@gmail.com";
      };
      bash = {
        enable = true;
        shellAliases = {
          build = "sudo nixos-rebuild switch --flake .";
          add = "git add .";
          commit = "git commit -m";
          push = "git push origin";
          branch = "git branch";
          checkout = "git checkout";
          merge = "git merge";
          nixos = "cd /etc/nixos";
          snano = "sudo nano";
          status = "sudo systemctl status";
          log = "sudo journalctl -n 50 -u";
        };
      };
      ssh = {
        enable = true;
        matchBlocks = {
          "github.com" = {
            host = "github.com";
            identityFile = "~/.ssh/id_ed25519";
            extraOptions = {
              AddKeysToAgent = "yes";
            };
          };
        };
      };
    };
  };
}