# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, unstable,... }:

{
  imports =
    [ 
    ./hardware-configuration.nix
    ./modules/system/boot.nix
    ./modules/system/users.nix
    ./modules/system/hardware.nix
    ./modules/system/networking.nix
    ./modules/system/localization.nix
    ./modules/system/desktop.nix
    ./modules/system/services.nix
    ./modules/system/packages.nix
    ];

  # ============================================================================
  # Nix Settings
  # ============================================================================
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-39.8.10"
    ];
    # cudaSupport = true;
    # 例如 RTX 30 系列是 "8.6"，RTX 40 系列是 "8.9"，A100 是 "8.0"
    # cudaCapabilities = [ "8.9" ]; 
  };
  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cuda-maintainers.cachix.org-1:0t9qX9ui8Mp74syH4IfyatuzwXUcH8WPWno8Y6isNTo="
      ];
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  system.stateVersion = "25.11";

}

