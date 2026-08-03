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
    home-manager
    podman-compose
    podman-tui

    flameshot
    zenity
    nur.repos.quriosity.tabby
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
      # libraries = with pkgs; [
      # ];
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
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.elisa
    kdePackages.spectacle
    kdePackages.qrca
    kdePackages.gwenview
    kdePackages.konsole
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
