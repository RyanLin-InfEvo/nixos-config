{ config, pkgs, inputs, unstable, master, lib, hostName,... }:
let
  openwork = pkgs.callPackage ./custom-pkgs/openwork/default.nix {};
  antigravity-cli = pkgs.callPackage ./custom-pkgs/antigravity-cli/default.nix {};
  google-antigravity = pkgs.callPackage ./custom-pkgs/google-antigravity/default.nix {};
  google-antigravity-ide = pkgs.callPackage ./custom-pkgs/google-antigravity-ide/default.nix {};
  gitnexus = pkgs.callPackage ./custom-pkgs/gitnexus/default.nix {};
  pearl-desktop-wallet = pkgs.callPackage ./custom-pkgs/pearl-desktop-wallet/default.nix {};
in
{
  home.packages = 
  (with pkgs; [
    # 系統與常用套件
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.filelight

    # PDF
    kdePackages.okular
    qpdfview
    
    unstable.pear-desktop
    
    kdotool
    google-chrome
    # zoom-us

    obsidian
    libreoffice-qt

    localsend
        
    bubblewrap
    sox
    appimage-run
    
    # inputs.whisper-dictation.packages.${stdenv.hostPlatform.system}.default
    
    # Development & Agent
    # opencode
    # openwork
    unstable.vscode
    screen
    antigravity-cli
    google-antigravity
    google-antigravity-ide
    gitnexus

    # Remote
    rustdesk

    # Crypto
    # pearl-desktop-wallet

    # Photo Editing
    unstable.darktable
    unstable.gimp
  ]) ++ (lib.optionals (hostName == "ryan-Desktop")) (with pkgs; [
    unstable.siril
    nodejs
    activitywatch
    #unstable.art
  ]);
}