{ config, pkgs, inputs, ... }:

{
  # --------------------------------------------------------------------------------------------------------
  # -------------------------------------------- PACKAGES --------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  imports = [
    inputs.hush.homeManagerModules.default
    # ...
  ];

  home.packages = with pkgs; [
    (prismlauncher.override {
      additionalPrograms = [ ffmpeg ];
      jdks = [
        zulu8
        zulu17
        zulu25
        zulu
      ];
    })
    droidcam
    tor-browser
    gitkraken
    faugus-launcher
    vmware-workstation
    materialgram
    hardinfo2
    vlc
    zed-editor
    keepassxc
    xnviewmp
    distrobox
    distrobox-tui
    kontainer

    nur.repos.trev.helium
    nur.repos.quriosity.zen-browser

    kdePackages.sddm-kcm
    kdePackages.partitionmanager
    kdePackages.ktorrent
    kdePackages.qtstyleplugin-kvantum
    kdePackages.kdenlive
  ];

  # OBS
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

  # hush (NVIDIA Maxine denoiser virtual microphone)
  services.hush.enable = true;

  # --------------------------------------------------------------------------------------------------------
  # -------------------------------------------- ENVVARS ---------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    NIX_PATH="nixos-config=/home/quriosity/nixconf/configuration.nix";
  };

  home = {
    username = "quriosity";
    homeDirectory = "/home/quriosity";
  };

  # --------------------------------------------------------------------------------------------------------
  # ------------------------------------------ DO NOT TOUCH ------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
}
