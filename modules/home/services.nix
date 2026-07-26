{ config, pkgs, inputs, lib, hostName, ... }:

{
  home.file.".config/whisper-dictation/config.yaml".text = ''
    hotkey:
      key: "Space"
      modifiers: ["Super"]
    
    general:
      language: "zh"
      model: "base"
  '';
  /*
  systemd.user.services.whisper-dictation = lib.mkIf (config.networking.hostName == "disable"){
    Unit = {
      Description = "Whisper Dictation Service";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [
        "GI_TYPELIB_PATH=${pkgs.glib.out}/lib/girepository-1.0:${pkgs.gobject-introspection.out}/lib/girepository-1.0:${pkgs.gtk4.out}/lib/girepository-1.0:${pkgs.gdk-pixbuf.out}/lib/girepository-1.0:${pkgs.graphene}/lib/girepository-1.0:${pkgs.pango.out}/lib/girepository-1.0:${pkgs.harfbuzz.out}/lib/girepository-1.0"
        "LD_LIBRARY_PATH=${pkgs.glib.out}/lib:${pkgs.gtk4}/lib"
        "YDOTOOL_SOCKET=/run/ydotoold/socket"
        "PATH=${pkgs.lib.makeBinPath [ pkgs.ydotool pkgs.glib.bin pkgs.procps ]}" # Home Manager 中通常透過這種方式注入 PATH
      ];
      ExecStart = "${inputs.whisper-dictation.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/whisper-dictation";
      Restart = "always";
      RestartSec = "5";
    };
  };
  */

  systemd.user.services.update-antigravity = {
    Unit = {
      Description = "Auto-update google-antigravity package";
    };
    Service = {
      Type = "oneshot";
      Environment = [
        "PATH=${pkgs.lib.makeBinPath [ pkgs.git pkgs.nix pkgs.python3 pkgs.bash pkgs.home-manager ]}"
      ];
      ExecStart = "${pkgs.writeShellScript "update-antigravity" ''
        set -euo pipefail
        cd ${config.home.homeDirectory}/nixos-config
        python3 modules/home/custom-pkgs/google-antigravity/update.py --auto
      ''}";
    };
  };

  systemd.user.timers.update-antigravity = {
    Unit = {
      Description = "Timer to auto-update google-antigravity package";
    };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  home.file.".config/activitywatch/aw-qt/aw-qt.toml".text = ''
    [aw-qt]
    autostart_modules = ["aw-server", "aw-watcher-afk"]
  '';

  systemd.user.services.aw-watcher-window-kwin = lib.mkIf (hostName == "ryan-Desktop"){
    Unit = {
      Description = "ActivityWatch Window Watcher for KDE Wayland (using kdotool)";
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [
        "PATH=${pkgs.lib.makeBinPath [ pkgs.kdotool pkgs.python3 pkgs.bash pkgs.coreutils ]}"
      ];
      ExecStart = "${pkgs.writeScript "aw-watcher-window-kwin" ''
        #!${pkgs.python3}/bin/python3
        import json
        import os
        import socket
        import subprocess
        import sys
        import time
        import urllib.request

        HOSTNAME = socket.gethostname()
        BUCKET_NAME = f"aw-watcher-window_{HOSTNAME}"
        SERVER_URL = "http://127.0.0.1:5600"

        def create_bucket():
            url = f"{SERVER_URL}/api/0/buckets/{BUCKET_NAME}"
            data = json.dumps({
                "client": "aw-watcher-window-kwin",
                "type": "currentwindow",
                "hostname": HOSTNAME
            }).encode("utf-8")
            req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
            try:
                urllib.request.urlopen(req)
            except Exception:
                pass

        def get_active_window():
            try:
                res_win = subprocess.run(["kdotool", "getactivewindow"], capture_output=True, text=True, timeout=1)
                if res_win.returncode != 0:
                    return None, None
                wid = res_win.stdout.strip()
                if not wid:
                    return None, None

                res_title = subprocess.run(["kdotool", "getwindowname", wid], capture_output=True, text=True, timeout=1)
                res_app = subprocess.run(["kdotool", "getwindowclassname", wid], capture_output=True, text=True, timeout=1)

                title = res_title.stdout.strip() if res_title.returncode == 0 else ""
                app = res_app.stdout.strip() if res_app.returncode == 0 else ""
                return app, title
            except Exception:
                return None, None

        def send_heartbeat(app, title):
            url = f"{SERVER_URL}/api/0/buckets/{BUCKET_NAME}/heartbeat?pulsetime=5"
            payload = {
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "duration": 0.0,
                "data": {
                    "app": app or "",
                    "title": title or ""
                }
            }
            data = json.dumps(payload).encode("utf-8")
            req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
            try:
                urllib.request.urlopen(req)
            except Exception:
                pass

        def main():
            create_bucket()
            while True:
                app, title = get_active_window()
                if app is not None and title is not None:
                    send_heartbeat(app, title)
                time.sleep(1)

        if __name__ == "__main__":
            main()
      ''}";
      Restart = "always";
      RestartSec = "3";
    };
  };
}