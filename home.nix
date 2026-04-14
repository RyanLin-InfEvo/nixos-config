# /etc/nixos/home.nix
{ config, pkgs, inputs, ... }:

{

# 這裡開始是 ryan 的 Home Manager 內部設定
home.stateVersion = "25.11";

home.packages = with pkgs; [
    kdePackages.kate
    kdePackages.kcalc
    youtube-music
    activitywatch
    google-chrome
    vscode
    obsidian
    libreoffice-qt
    bitwarden-desktop
    localsend
    kdePackages.okular
    texlive.combined.scheme-full
    inputs.antigravity-nix.packages.${pkgs.system}.default
];

programs.git = {
    enable = true;
    settings = {
    user.name = "RyanLin-InfEvo";
    user.email = "ryanarduino0410@gmail.com";
    };
};

xdg.configFile."fcitx5/conf/classicui.conf".text = ''
    Theme=OriLight
    DarkTheme=OriDark
    UseDarkTheme=True
'';

}
