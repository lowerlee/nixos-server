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
        };
      };
    };

    xdg.configFile."qBittorrent/qBittorrent.conf".text = ''
      [Preferences]
      WebUI\Username=admin
      WebUI\Password_PBKDF2="@ByteArray(AUDBiaMILHUAYYqVJOqBhg==:QX+kqYJns0Q8yRhDTXJoXw6s5g1RYrJzFO+YHAnPqYI5U0S6BIUhpd/2QeF0qF2H4qsGT/XNhO3FtD7oUs6aug==)"
    '';
  };
}
