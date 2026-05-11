{ inputs, pkgs, ... }:
let
  tg-ws-proxy-pkg = inputs.tg-ws-proxy.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = [ tg-ws-proxy-pkg ];

  systemd.user.services.tg-ws-proxy = {
    Unit = {
      Description = "Telegram WS Proxy";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${pkgs.bash}/bin/bash -c '${tg-ws-proxy-pkg}/bin/tg-ws-proxy --dc 2 --secret \"$TG_SECRET\"'";
      EnvironmentFile = "%h/.config/tg-ws-proxy/env";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
