{ lib, inputs, pkgs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
  ];

  programs.spicetify = {
    enable = true;

    theme = spicePkgs.themes.bloom;
    colorScheme = "dark";

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      shuffle
      adblock
      volumePercentage
      beautifulLyrics
      sidebarCustomizer
    ];

    enabledSnippets = with spicePkgs.snippets; [
      rotatingCoverart
      pointer
      modernScrollbar
      betterLyricsStyle
      removeRecentlyPlayed
      removePopular
      hideLikedSongsCard
      removeConnectBar
      autoHideFriends
      alwaysShowForward
      hideRecentSearches
      fullscreenHidePlayingFrom
      hideNowPlayingViewButton
      centeredLyrics
      smoothProgressBar
      hideDownloadButton
      removeTopSpacing
      hideFriendActivityButton
      hideWhatsNewButton
      smallerRightSidebarCover
      hidePodcastButton
      hideAudiobooksButton
      hideMiniPlayerButton
      fixMainViewWidth
      hideSidebarScrollbar
      leftAlignedHeartIcons
    ];

    enabledCustomApps = with spicePkgs.apps; [
      marketplace
      lyricsPlus
    ];
  };
}
