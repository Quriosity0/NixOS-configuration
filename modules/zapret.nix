{ ... }:
{
  services.zapret-discord-youtube = {
    enable = true;
    configName = "general(ALT)";  # choosing config
    gameFilter = "null";       # "null", "all", "tcp" or "udp"
    listGeneral = [ "rutracker.org" "github.com" "steambrew.app" "itch.io" "steamcommunity.com" "steampowered.com" ];  # additional domains
    listExclude = [ "microsoft365.com" "office.com" "cloud.microsoft" "microsoft.com" "office.net" ]; # exclude these adresses
  };
}
