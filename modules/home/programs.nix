{ config, pkgs, inputs, ... }:
{
  programs.bash.enable = true;

  programs.git = {
    enable = true;
    settings = {
    user.name = "RyanLin-InfEvo";
    user.email = "ryanarduino0410@gmail.com";
    };
  };

  home.file.".config/mpv/shaders/FSRCNNX_x2_16-0-4-1.glsl".source = pkgs.fetchurl {
    url = "https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/FSRCNNX_x2_16-0-4-1.glsl";
    sha256 = "0rcr3hp3mk2pgn2p1xzp7idw4i0a8q61afq5g9zkz6jx3qklm8nm";
  };

  home.file.".config/mpv/scripts/simple-history.lua".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Eisa01/mpv-scripts/refs/heads/master/scripts/SimpleHistory.lua";
    sha256 = "08055mpsdpw41qcfx8zahnav215pls5w8s9az6vv9ssm73fgdfhw";
  };

  programs.mpv = {
    enable = true;
    config = {
      vo = "gpu-next";
      gpu-api = "vulkan";
      hwdec = "nvdec";
      glsl-shaders = "~~/shaders/FSRCNNX_x2_16-0-4-1.glsl";
    };
    scripts = with pkgs.mpvScripts; [
      uosc
      thumbfast
      autoload  # load videos under same folder
      mpris # Media Player Remote Interfacing Specification
    ];
  };


  programs.obs-studio = {
    enable = false;
    package = pkgs.obs-studio.override {
      ffmpeg = pkgs.ffmpeg_7-full;
    };
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
    ];
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    icons = "auto";
  };

  programs.bat = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];
  };

  home.shellAliases = {
    cat = "bat";
    ls = "eza";
    ll = "eza -l";
    la = "eza -a";
    lt = "eza --tree";
    lla = "eza -la";
  };

}