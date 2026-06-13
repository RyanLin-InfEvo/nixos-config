{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  networking.hostName = "ryan-Desktop";

  # Desktop-specific boot configurations
  boot = {
    kernelModules = [ "nct6775" "asus_ec_sensors" ];
    tmp.tmpfsSize = "32G";
  };

  # Desktop-specific graphics and NVIDIA configurations
  hardware = {
    graphics = {
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # Desktop-specific Ollama settings
  services.ollama.acceleration = "cuda";
}
