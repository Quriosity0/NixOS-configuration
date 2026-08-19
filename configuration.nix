{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos>
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
          wallpapers = [ pkgs.nixos-artwork.wallpapers.simple-dark-gray.kdeFilePath ];
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
      open = true;
      nvidiaSettings = false;
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
    podman-compose
    podman-tui

    flameshot
    zenity
    nur.repos.quriosity.tabby
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
        clean-gens = "sudo nix-collect-garbage -d";
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

  quriosity = {
    sddm-themes = {
      echo = {
        enable = true;
      };
    };
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
      nerd-fonts.ubuntu-mono
      (google-fonts.override {
        fonts = [ "MontserratAlternates" ];
      })
    ];
  };

  # exclude kde apps
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
    gnome-calendar
    gnome-characters
    gnome-contacts
    gnome-font-viewer
    gnome-maps
    gnome-music
    gnome-system-monitor
    gnome-weather
    loupe
    showtime
    simple-scan
    yelp
    snapshot
    decibels
    epiphany
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
          ]);
      };
    };
    desktopManager.gnome.enable = true;
    gnome = {
      core-developer-tools.enable = false;
      games.enable = false;
    };
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

  # --------------------------------------------------------------------------------------------------------
  # ------------------------------------- HOME MANAGER CONFIGURATION ---------------------------------------
  # --------------------------------------------------------------------------------------------------------

  home-manager.users.quriosity = { pkgs, ... }: {
    home = {
      stateVersion = "25.11";
      packages = with pkgs; [
        (prismlauncher.override {
          additionalPrograms = [ ffmpeg ];
          jdks = [
            temurin-bin-8
            temurin-bin-17
            temurin-bin-25
          ];
        })
        droidcam
        sourcegit
        faugus-launcher
        vmware-workstation
        materialgram
        hardinfo2
        vlc
        zed-editor
        xnviewmp
        distrobox
        distrobox-tui
        boxbuddy

        nur.repos.trev.helium
        nur.repos.quriosity.zen-browser
        nur.repos.quriosity.BedrockNix

        transmission_4-gtk
        qt6Packages.qtstyleplugin-kvantum
        kdePackages.kdenlive

        gnome-tweaks
        refine
        gnomeExtensions.blur-my-shell
        gnomeExtensions.dash2dock-lite
        gnomeExtensions.just-perfection
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.app-hider
        gnomeExtensions.rounded-window-corners-reborn
        gnomeExtensions.caffeine
        gnomeExtensions.tiling-shell
        gnomeExtensions.status-tray
        gnomeExtensions.user-themes
      ];
      username = "quriosity";
      homeDirectory = "/home/quriosity";
    };

    programs = {
      obs-studio = {
        enable = true;
        package = (
          pkgs.obs-studio.override {
            cudaSupport = true;
          }
        );
        plugins = with pkgs.obs-studio-plugins; [
          obs-backgroundremoval
          obs-pipewire-audio-capture
          obs-vaapi
          obs-gstreamer
          obs-vkcapture
          input-overlay
          obs-multi-rtmp
          obs-livesplit-one
        ];
      };
    };

    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          enabled-extensions = [
            pkgs.gnomeExtensions.blur-my-shell.extensionUuid
            pkgs.gnomeExtensions.dash2dock-lite.extensionUuid
            pkgs.gnomeExtensions.just-perfection.extensionUuid
            pkgs.gnomeExtensions.clipboard-indicator.extensionUuid
            pkgs.gnomeExtensions.app-hider.extensionUuid
            pkgs.gnomeExtensions.rounded-window-corners-reborn.extensionUuid
            pkgs.gnomeExtensions.caffeine.extensionUuid
            pkgs.gnomeExtensions.tiling-shell.extensionUuid
            pkgs.gnomeExtensions.status-tray.extensionUuid
            pkgs.gnomeExtensions.user-themes.extensionUuid
          ];
        };
      };
    };
    nixpkgs.config.allowUnfree = true;
  };
}
