# /etc/nixos/home.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/packages.nix
    ./modules/home/programs.nix
    ./modules/home/services.nix
  ];
  
  home.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;

  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  home.sessionVariables = {
    # ANTIGRAVITY_SANDBOX is supported for custom commands like 'bwai'
    # Use 'bwai' directly to run agy if needed: bwai agy ...
  };

  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
      Theme=OriLight
      DarkTheme=OriDark
      UseDarkTheme=True
  '';

}
