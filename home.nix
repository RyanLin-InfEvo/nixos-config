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
    # GEMINI_SANDBOX is NOT supported for custom commands like 'bwai'
    # Use 'bwai' directly to run gemini if needed: bwai gemini ...
  };

  xdg.configFile."fcitx5/conf/classicui.conf".text = ''
      Theme=OriLight
      DarkTheme=OriDark
      UseDarkTheme=True
  '';

}
