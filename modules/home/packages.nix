{ config, pkgs, inputs, unstable, master, ... }:
let
  openwork = pkgs.callPackage ./custom-pkgs/openwork/default.nix {};
  bubblewrap-ai = pkgs.callPackage ./custom-pkgs/bubblewrap-ai/default.nix {};
in
{
  home.packages = with pkgs; [
    # 系統與常用套件
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.filelight
    kdePackages.okular
    youtube-music
    activitywatch
    google-chrome
    zoom-us
    
    obsidian
    libreoffice-qt
    bitwarden-desktop
    localsend
    
    nodejs
    bubblewrap
    bubblewrap-ai
    
    # Development & Agent
    opencode
    # openwork
    vscode
    screen
    inputs.antigravity-nix.packages.${stdenv.hostPlatform.system}.default

  ] ++ [
    # from unstable
    # unstable.gemini-cli
    master.gemini-cli
  ];
}