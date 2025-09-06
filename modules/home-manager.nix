{ config, pkgs, ... }:

{
  home-manager.users.k = { pkgs, ... }: {  
    home.stateVersion = "24.11";           

    home.packages = with pkgs; [
      # other packages here
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

          mountnas = "sudo mount -t nfs 100.112.79.28:/volume1/media /mnt/media";
        };
        bashrcExtra = ''
          # git fetch and reset to a specific branch
          fetch() {
            git fetch origin

            echo "Enter branch name to reset to:"
            read branch_name
            git reset --hard origin/$branch_name
          }

          # git commit and push with a message
          newcommit() {
            cd /etc/nixos

            git add .

            echo -n "Enter commit message: "
            read commit_msg
            git commit -m "$commit_msg"

            echo -n "Enter branch to push to: "
            read branch_name
            git push origin "$branch_name"
          }

          build() {
            cd /etc/nixos

            git add .
        
            echo -n "Enter commit message: "
            read commit_msg
            git commit -m "$commit_msg"

            sudo nixos-rebuild switch
          }
        '';
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