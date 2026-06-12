{ config, pkgs, inputs, unstable, master, ... }:
let
  openwork = pkgs.callPackage ./custom-pkgs/openwork/default.nix {};
  bubblewrap-ai = pkgs.callPackage ./custom-pkgs/bubblewrap-ai/default.nix {};
  antigravity-cli = pkgs.callPackage ./custom-pkgs/antigravity-cli/default.nix {};
  google-antigravity = pkgs.callPackage ./custom-pkgs/google-antigravity/default.nix {};
  google-antigravity-ide = pkgs.callPackage ./custom-pkgs/google-antigravity-ide/default.nix {};
  gitnexus = pkgs.callPackage ./custom-pkgs/gitnexus/default.nix {};
  pearl-desktop-wallet = pkgs.callPackage ./custom-pkgs/pearl-desktop-wallet/default.nix {};
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
    
    fzf
    obsidian
    libreoffice-qt
    bitwarden-desktop
    localsend
    
    nodejs
    bubblewrap
    bubblewrap-ai
    sox
    
    inputs.whisper-dictation.packages.${stdenv.hostPlatform.system}.default
    
    # Development & Agent
    # opencode
    # openwork
    unstable.vscode
    screen
    antigravity-cli
    google-antigravity
    google-antigravity-ide
    gitnexus
    pearl-desktop-wallet
  ] ++ [
    # from unstable
    # unstable.gemini-cli
    master.gemini-cli
  ];
}