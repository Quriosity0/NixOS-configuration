{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      # ...
    ];

  # --------------------------------------------------------------------------------------------------------
  # -----------------------------------------       BOOTING      -------------------------------------------
  # ----------------------------------------- AND BASIC SETTINGS -------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;


  boot.kernelPackages = pkgs.linuxPackages_latest;


  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  boot.kernelModules = [ "v4l2loopback" "ntsync" ];

  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';

  security.polkit.enable = true;

  networking.hostName = "asuspc";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.quriosity = {
    isNormalUser = true;
    description = "Quriosity";
    extraGroups = [ "networkmanager" "wheel" "docker" "kvm" ];
    packages = with pkgs; [];
  };

  # --------------------------------------------------------------------------------------------------------
  # ------------------------------------------ NVIDIA DRIVER -----------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };


  # --------------------------------------------------------------------------------------------------------
  # -------------------------------------------- PACKAGES --------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  # packages installation
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    fastfetch
    btop
    firefox
    gnupg
    home-manager

    kdePackages.sddm-kcm
    kdePackages.partitionmanager
    kdePackages.ktorrent
    kdePackages.qtstyleplugin-kvantum
    kdePackages.kdenlive

    materialgram
    hardinfo2
    vlc
    flameshot
    zenity
    cursor-cli
    vmware-workstation
  ];

  # fonts
  fonts.packages = with pkgs; [
    freetype
    fontconfig
    dejavu_fonts
    (google-fonts.override {
      fonts = [ "MontserratAlternates" ];
    })
  ];

  # exclude useless kde apps
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.elisa
    kdePackages.spectacle
    kdePackages.qrca
  ];

  # Steam
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;
  dedicatedServer.openFirewall = true;
  protontricks.enable = true;
  package = pkgs.millennium-steam.override {
    extraPkgs = pkgs: with pkgs; [
      freetype fontconfig
      xorg.libXcursor xorg.libXi xorg.libXinerama xorg.libXScrnSaver
      libpng libpulseaudio
      ];
    };
  };

  # appimage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # setting libs to run apps through terminal
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd

      SDL2
      libGL
      libGLU
      libx11
      libxi
      libpng
    ];
  };

  programs.amnezia-vpn.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.vmware.host.enable = true;

  # --------------------------------------------------------------------------------------------------------
  # -------------------------------------------- SERVICES --------------------------------------------------
  # --------------------------------------------  ENVVARS --------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  services = {
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;
    flatpak.enable = true;
    zerotierone.enable = true;
  };

  programs.coolercontrol.enable = true;
  environment.stub-ld.enable = false;
  boot.tmp.cleanOnBoot = true;

  nix.nixPath = [
    "nixos-config=/home/quriosity/nixconf/configuration.nix"
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];


  # --------------------------------------------------------------------------------------------------------
  # ------------------------------------------ NETWORKING --------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # services.openssh.enable = true;

  networking.hosts = {
    "72.56.93.144" = [
      "a-api.anthropic.com"
      "a-cdn.anthropic.com"
      "anthropic.com"
      "api.anthropic.com"
      "api.claude.ai"
      "api.console.anthropic.com"
      "auth.anthropic.com"
      "claude.ai"
      "console.anthropic.com"
      "s-cdn.anthropic.com"
      "statsig.anthropic.com"
      "status.anthropic.com"
      "support.anthropic.com"
      "www.anthropic.com"
      "www.claude.ai"
      "platform.claude.com"
      "ab.chatgpt.com"
      "android.chat.openai.com"
      "api.openai.com"
      "arena.openai.com"
      "auth.openai.com"
      "auth0.openai.com"
      "beta.api.openai.com"
      "beta.openai.com"
      "blog.openai.com"
      "cdn.auth0.com"
      "cdn.oaistatic.com"
      "cdn.openai.com"
      "chat.openai.com"
      "chatgpt.com"
      "community.openai.com"
      "contest.openai.com"
      "d.docs.live.net"
      "debate-game.openai.com"
      "discuss.openai.com"
      "files.oaiusercontent.com"
      "gpt3-openai.com"
      "gym.openai.com"
      "help.openai.com"
      "ios.chat.openai.com"
      "jukebox.openai.com"
      "labs.openai.com"
      "microscope.openai.com"
      "mobile.events.data.microsoft.com"
      "oaistatic.com"
      "openai.com"
      "operator.chatgpt.com"
      "platform.api.openai.com"
      "platform.openai.com"
      "realtime.chatgpt.com"
      "ws.chatgpt.com"
      "sora.chatgpt.com"
      "sora.com"
      "spinningup.openai.com"
      "tcr9i.chat.openai.com"
      "universe.openai.com"
      "videos.openai.com"
      "webrtc.chatgpt.com"
      "www.chatgpt.com"
      "www.openai.com"
    ];
    "0.0.0.0" = [
      "paradise-s1.battleye.com"
      "test-s1.battleye.com"
      "paradiseenhanced-s1.battleye.com"
    ];
  };

  # networking.firewall.enable = false;

  # --------------------------------------------------------------------------------------------------------
  # ------------------------------------------ DO NOT TOUCH ------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11";

}
