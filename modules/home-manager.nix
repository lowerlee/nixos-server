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
          # system alias
          build = "sudo nixos-rebuild switch --flake .";
          nixos = "cd /etc/nixos";
          snano = "sudo nano";
          status = "sudo systemctl status";
          log = "sudo journalctl -n 50 -u";

          # git aliases
          add = "git add .";
          commit = "git commit -m";
          push = "git push origin";
          branch = "git branch";
          checkout = "git checkout";
          merge = "git merge";
          newbranch = "git checkout -b";
          pushup = "git push -u origin";
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