{ config, pkgs, ... }:
{
  # ============================================================================
  # hardware
  # ============================================================================
  hardware.i2c.enable = true;


  # ============================================================================
  # Graphics / NVIDIA
  # ============================================================================
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
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

  # ============================================================================
  # Audio (PipeWire - replacing PulseAudio)
  # ============================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };


  # ============================================================================
  # Mouse / Touchpad
  # ============================================================================
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    model = "pc105";
    variant = "";
  };
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

}
