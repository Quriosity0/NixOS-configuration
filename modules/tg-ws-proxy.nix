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
      ExecStartPost = "${pkgs.bash}/bin/bash -c 'sleep 2 && ${pkgs.libnotify}/bin/notify-send -t 0 \"tg-ws-proxy\" \"$(journalctl --user -u tg-ws-proxy -n 30 --no-pager | grep \"tg://\" | sed \"s/.*tg:/tg:/\")'";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
