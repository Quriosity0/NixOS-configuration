{ inputs, pkgs, ... }:
let
  tg-ws-proxy-pkg = inputs.tg-ws-proxy.packages.${pkgs.stdenv.hostPlatform.system}.default;
  notify-script = pkgs.writeShellScript "tg-ws-proxy-notify" ''
    sleep 2
    link=$(journalctl --user -u tg-ws-proxy -n 30 --no-pager | grep "tg://" | sed "s/.*tg:/tg:/")
    ${pkgs.libnotify}/bin/notify-send -t 0 "tg-ws-proxy" "$link"
  '';
in
{
  home.packages = [ tg-ws-proxy-pkg ];

  systemd.user.services.tg-ws-proxy = {
    Unit = {
      Description = "Telegram WS Proxy";
      After = [ "network.target" ];
    };

    Service = {
      ExecStart = "${tg-ws-proxy-pkg}/bin/tg-ws-proxy --port 1080 --dc-ip 2:149.154.167.220 --dc-ip 4:149.154.167.220";
      ExecStartPost = "${notify-script}";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
