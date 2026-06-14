{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../configuration.nix
  ];

  networking.hostName = "ryan-dynabook";

  # Dynabook-specific boot configurations (16GB RAM laptop)
  boot = {
    tmp.tmpfsSize = "8G"; # Safe size for 16GB RAM
  };

  # Intel integrated graphics hardware acceleration (VA-API)
  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };

  # Dynabook-specific system packages
  environment.systemPackages = with pkgs; [
    nvtopPackages.intel
  ];
}
