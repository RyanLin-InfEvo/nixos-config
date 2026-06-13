{ config, pkgs, ... }:
{
  networking = {
    networkmanager.enable = true;
    # Firewall (ufw equivalent)
    firewall = {
      enable = true;
      allowedTCPPorts = [
        53317 # localsend
      ];
      allowedUDPPorts = [
        53317 # localsend (discovery)
      ];
    };
  };
}