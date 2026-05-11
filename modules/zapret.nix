{ ... }:
{
  services.zapret-discord-youtube = {
    enable = true;
    config = "general(ALT)";  # choosing config
    gameFilter = "null";       # "null", "all", "tcp" or "udp"
    listGeneral = [ "rutracker.org" "github.com" "steambrew.app" "itch.io" "steamcommunity.com" "steampowered.com" ];  # additional domains
  };
}
