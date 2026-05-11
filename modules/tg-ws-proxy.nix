{ inputs, pkgs, ... }:
{
  home.packages = [
    inputs.tg-ws-proxy.packages.${pkgs.system}.default
  ];

  systemd.user.services.tg-ws-proxy = {
    Unit = {
      Description = "Telegram WS Proxy";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${inputs.tg-ws-proxy.packages.${pkgs.system}.default}/bin/tg-ws-proxy --dc 2 --secret \${TG_SECRET}";
      EnvironmentFile = "%h/.config/tg-ws-proxy/env";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
