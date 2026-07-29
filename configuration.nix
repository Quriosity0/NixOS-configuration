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

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      limine = {
        enable = true;
        efiInstallAsRemovable = true;
        resolution = "1920x1080";
        maxGenerations = 10;
        style = {
          wallpapers = [ pkgs.nixos-artwork.wallpapers.gear.kdeFilePath ];
          interface = {
            branding = "NixOS";
          };
        };
      };
      efi.canTouchEfiVariables = true;
    };
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
    kernelModules = [ "v4l2loopback" "ntsync" ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
    tmp.cleanOnBoot = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  users.users = {
    quriosity = {
      isNormalUser = true;
      description = "Quriosity";
      extraGroups = [ "networkmanager" "wheel" "kvm" ];
      shell = pkgs.zsh;
    };
  };

  security.polkit.enable = true;
  networking.hostName = "asuspc";
  time.timeZone = "Europe/Moscow";
  system.nixos.label = "NixOS";

  # --------------------------------------------------------------------------------------------------------
  # ---------------------------------------- HARDWARE DRIVERS ----------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  hardware = {
    graphics = {
      enable = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
    openrazer = {
      enable = true;
      users = ["quriosity"];
    };
    nvidia-container-toolkit.enable = true;
  };

  # --------------------------------------------------------------------------------------------------------
  # -------------------------------------------- PACKAGES --------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  # Package installation
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    fastfetch
    btop
    gnupg
    gdu
    home-manager
    podman-compose
    podman-tui
    github-cli

    flameshot
    zenity
    #nur.repos.quriosity tabby/hyper
    nur.repos.quriosity.echo-sddm
  ];

  # Package settings
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      protontricks.enable = true;
      package = pkgs.millennium-steam.override {
        extraPkgs = pkgs: with pkgs; [
          freetype fontconfig libXcursor libXi libXinerama libXScrnSaver libpng libpulseaudio
        ];
      };
    };
    appimage = {
      enable = true;
      binfmt = true;
    };
    nix-ld = {
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
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [
          "web-search"
          "z"
          "sudo"
          "gpg-agent"
        ];
        theme = "ys";
      };
      shellAliases = {
        la = "ls -la";
        cls = "clear";
        flpull = "nix flake update";
        flchk = "nix flake check";
        update = "sudo nixos-rebuild switch --flake ~/nixconf#asuspc && home-manager switch --flake ~/nixconf#quriosity";
      };
      histSize = 10000;
      histFile = "$HOME/.zsh_history";
      setOptions = [
        "HIST_IGNORE_ALL_DUPS"
      ];
    };
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    amnezia-vpn.enable = true;
    mtr.enable = true;
  };

  # Virtualisation (podman/docker and virtual machines)
  virtualisation = {
    containers = {
      enable = true;
    };
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    vmware = {
      host = {
        enable = true;
      };
    };
  };

  # fonts
  fonts = {
    packages = with pkgs; [
      freetype
      fontconfig
      dejavu_fonts
      nerd-fonts.jetbrains-mono
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
      (google-fonts.override {
        fonts = [ "MontserratAlternates" ];
      })
    ];
  };

  # exclude kde apps
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.elisa
    kdePackages.spectacle
    kdePackages.qrca
    kdePackages.gwenview
    #kdePackages.konsole # remove comment and switch to other terminal emulator
  ];

  # --------------------------------------------------------------------------------------------------------
  # -------------------------------------------- SERVICES --------------------------------------------------
  # --------------------------------------------  ENVVARS --------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  services = {
    xserver ={
      xkb = {
        layout = "us";
        variant = "";
      };
      videoDrivers = ["nvidia"];
    };
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        theme = "echo";
        extraPackages = (with pkgs.qt6; [
            qtsvg
            qtdeclarative
            qt5compat
          ]) ++ [ pkgs.nur.repos.quriosity.echo-sddm ];
      };
    };
    desktopManager.plasma6.enable = true;
    flatpak.enable = true;
  };

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    nixPath = [
      "nixos-config=/home/quriosity/nixconf/configuration.nix"
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  environment.stub-ld.enable = false;

  # --------------------------------------------------------------------------------------------------------
  # ------------------------------------------ NETWORKING --------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  # services.openssh.enable = true;

  networking = {
    networkmanager.enable = true;
    hosts = {
      # OpenAI/anthropic rufix
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
      # GTA Online fix
      "0.0.0.0" = [
        "paradise-s1.battleye.com"
        "test-s1.battleye.com"
        "paradiseenhanced-s1.battleye.com"
      ];
    };
  };

  # --------------------------------------------------------------------------------------------------------
  # ------------------------------------------ DO NOT TOUCH ------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}
