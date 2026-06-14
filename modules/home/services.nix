{ config, pkgs, inputs, ... }:

{
  home.file.".config/whisper-dictation/config.yaml".text = ''
    hotkey:
      key: "Space"
      modifiers: ["Super"]
    
    general:
      language: "zh"
      model: "base"
  '';
  systemd.user.services.whisper-dictation = {
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
}