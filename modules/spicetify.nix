{ lib, inputs, pkgs, ... }:

let
  # Access the spicetify packages for your system
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "spotify" ];

  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
  ];

  programs.spicetify = {
    enable = true;

    # Enabled theme and color scheme
    theme = spicePkgs.themes.fluent;
    colorScheme = "dark";

    # Enabled extensions
    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shuffle
    ];

    # Enabled snippets
    enabledSnippets = with spicePkgs.snippets; [
      rotatingCoverart
      pointer
    ];

    # Enabled custom apps
    enabledCustomApps = with spicePkgs.apps; [
      marketplace
      lyricsPlus
    ];
  };
}
