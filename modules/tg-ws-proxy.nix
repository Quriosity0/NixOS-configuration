{ inputs, pkgs, ... }:
let
  tg-ws-proxy-pkg = inputs.tg-ws-proxy.packages.${pkgs.stdenv.hostPlatform.system}.default;

  connect-script = pkgs.writeShellApplication {
  name = "tg-ws-proxy-connect";
  runtimeInputs = [ pkgs.xdg-utils pkgs.systemd pkgs.procps ];
  text = ''
    attempts=0
    while [ "$attempts" -lt 60 ]; do
      if pgrep -f "materialgram" > /dev/null; then
        sleep 2
        link=$(journalctl --user -u tg-ws-proxy -n 30 --no-pager \
          | grep "tg://" \
          | sed "s/.*tg:/tg:/")
        if [ -n "$link" ]; then
          xdg-open "$link"
        fi
        exit 0
      fi
      attempts=$((attempts + 1))
      sleep 5
    done
  '';
  };
in
{
  home.packages = [ tg-ws-proxy-pkg ];

  systemd.user.services.tg-ws-proxy = {
    Unit = {
      Description = "Telegram WS Proxy";
      After = [ "network.target" "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${tg-ws-proxy-pkg}/bin/tg-ws-proxy --port 1080 --dc-ip 2:149.154.167.220 --dc-ip 4:149.154.167.220";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.tg-proxy-connect = {
    Unit = {
      Description = "Connect Telegram to MTProxy after launch";
      After = [ "tg-ws-proxy.service" "graphical-session.target" ];
      Wants = [ "tg-ws-proxy.service" ];
      ConditionPathExists = "!/tmp/tg-proxy-connected";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${connect-script}/bin/tg-ws-proxy-connect";
      ExecStartPost = "${pkgs.coreutils}/bin/touch /tmp/tg-proxy-connected";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
