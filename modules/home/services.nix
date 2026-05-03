{ config, pkgs, inputs, ... }:

{
  systemd.user.services.whisper-dictation = {
    Unit = {
      Description = "Whisper Dictation Service";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Environment = [
        "GI_TYPELIB_PATH=${pkgs.glib.out}/lib/girepository-1.0:${pkgs.gtk3.out}/lib/girepository-1.0:${pkgs.gdk-pixbuf}/lib/girepository-1.0"
        "YDOTOOL_SOCKET=/run/ydotoold/socket"
        "PATH=${pkgs.lib.makeBinPath [ pkgs.ydotool ]}" # Home Manager 中通常透過這種方式注入 PATH
      ];
      ExecStart = "${inputs.whisper-dictation.packages.${pkgs.system}.default}/bin/whisper-dictation";
      Restart = "always";
      RestartSec = "5";
    };
  };
}