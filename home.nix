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
    discord
    (prismlauncher.override {
      additionalPrograms = [ ffmpeg ];
      jdks = [
        zulu8
        zulu17
        zulu25
        zulu
      ];
    })
    docker
    docker-compose
    droidcam
    tor-browser
    gitkraken
    haguichi
    faugus-launcher
  ];

  # OBS
  programs.obs-studio = {
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

  # hush (NVIDIA Maxine denoiser virtual microphone)
  services.hush.enable = true;

  # --------------------------------------------------------------------------------------------------------
  # -------------------------------------------- ENVVARS ---------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    NIX_PATH="nixos-config=/home/quriosity/nixconf/configuration.nix";
  };

  # --------------------------------------------------------------------------------------------------------
  # ------------------------------------------ DO NOT TOUCH ------------------------------------------------
  # --------------------------------------------------------------------------------------------------------

  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
  home.username = "quriosity";
  home.homeDirectory = "/home/quriosity";
  nixpkgs.config.allowUnfree = true;
}
