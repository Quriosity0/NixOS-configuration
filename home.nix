{ config, pkgs, inputs, ... }:

{
  # --------------------------------------------------------------------------------------------------------
  # -------------------------------------------- PACKAGES --------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  imports = [
    # ...
  ];

  home.packages = with pkgs; [
    (prismlauncher.override {
      additionalPrograms = [ ffmpeg ];
      jdks = [
        temurin-bin-8
        temurin-bin-17
        temurin-bin-25
      ];
    })
    droidcam
    gitkraken
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

    transmission_4
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
    gnomeExtensions.tray-toggle
    gnomeExtensions.media-controls
    gnomeExtensions.user-themes
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

    dconf = {
        enable = true;
        settings = {
          "org/gnome/shell" = {
            # disable-user-extensions = true; # Optionally disable user extensions entirely
            enabled-extensions = [
              gnomeExtensions.blur-my-shell.extensionUuid
              gnomeExtensions.dash2dock-lite.extensionUuid
              gnomeExtensions.just-perfection.extensionUuid
              gnomeExtensions.clipboard-indicator.extensionUuid
              gnomeExtensions.app-hider.extensionUuid
              gnomeExtensions.rounded-window-corners-reborn.extensionUuid
              gnomeExtensions.caffeine.extensionUuid
              gnomeExtensions.tiling-shell.extensionUuid
              gnomeExtensions.tray-toggle.extensionUuid
              gnomeExtensions.media-controls.extensionUuid
              gnomeExtensions.user-themes.extensionUuid
            ];
          };
          # Configure individual extensions
          #"org/gnome/shell/extensions/blur-my-shell" = {
          #  brightness = 0.75;
          #  noise-amount = 0;
          };
        };
      };
  };

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
