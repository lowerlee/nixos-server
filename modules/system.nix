{ config, pkgs, ... }:

{
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
    extraConfig = ''
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      HandleLidSwitch=ignore
      HandleLidSwitchExternalPower=ignore
      HandleLidSwitchDocked=ignore
    '';
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

  powerManagement = {
    enable = true;
    powertop.enable = false;
  };

  boot.kernelParams = [
    "i8042.nopnp"
    "i8042.reset" 
    "i8042.nomux"
  ];

  systemd.tmpfiles.rules = [
    "d /mnt 0755 root root"
    "d /mnt/media 0777 k users"
  ];

  fileSystems."/mnt/media" = {
    device = "100.112.79.28:/volume1/media";
    fsType = "nfs";
    options = [ 
      "noauto"
      "_netdev"
      "x-systemd.automount"
      "x-systemd.mount-timeout=10"
      "timeo=15"
      "rsize=8192"
      "wsize=8192"
      "soft"
      "nofail"
      "intr"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    tree
    tailscale
    qbittorrent-nox
    jellyfin
    docker
    miniflux
    rsshub
    nfs-utils
    rpcbind
    podman
  ];

  services.openssh.enable = true;
}

