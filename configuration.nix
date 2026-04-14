# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs,... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # ============================================================================
  # Boot
  # ============================================================================
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "quiet" "splash" ];
    # blacklistedKernelModules = [ "spd5118" ];
    # Use the latest kernel for best hardware support (i5-14500 / Raptor Lake)
    kernelPackages = pkgs.linuxPackages_latest;
    # Swap file
    kernel.sysctl = {
      "vm.swappiness" = 120;  # Due to zramSwap, pretend to zipRamSwap rather than Drop page cache
      "vm.vfs_cache_pressure" = 50; # Dirs and Files will stay in Ram for longer time
      "vm.dirty_background_ratio" = 20;
      "vm.dirty_ratio" = 60;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100; # Ensure priority higher than disk swap
  };


  # ============================================================================
  # hardware
  # ============================================================================
    hardware.i2c.enable = true;


  # ============================================================================
  # Networking
  # ============================================================================
  networking = {
    hostName = "ryan-Desktop";
    networkmanager.enable = true;
    # Firewall (ufw equivalent)
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # SSH
        8384  # Resilio Sync Web UI
        # Sunshine ports
        47984 47989 47990 48010
        53317 #localsend
      ];
      allowedUDPPorts = [
        # Sunshine
        47998 47999 48000 48002 48010
        # ZeroTier
        9993
      ];
    };
  };

  # ============================================================================
  # Graphics / NVIDIA
  # ============================================================================
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false; # Use proprietary driver
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  # ============================================================================
  # Locale / Timezone / Keyboard
  # ============================================================================

  # Set your time zone.
  time.timeZone = "Asia/Taipei";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    };
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_TW.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.waylandFrontend = true;
      #fcitx5.settings.globalOptions = {
      #  Hotkey = {
      #    TriggerKeys = "Shift+Space";
      #  };
      #};
      fcitx5.addons = with pkgs; [
        fcitx5-chewing
        qt6Packages.fcitx5-chinese-addons
        fcitx5-gtk
        # Ori-fcitx5 OriDark theme
        # https://github.com/Reverier-Xu/Ori-fcitx5
        (stdenvNoCC.mkDerivation {
          pname = "fcitx5-theme-ori";
          version = "unstable";
          src = fetchFromGitHub {
            owner = "Reverier-Xu";
            repo = "Ori-fcitx5";
            rev = "master";
            hash = "sha256-46O/wCRphjVkYCbr29QqyiGBG27u3UG2DnrInZSQkIA=";
          };
          installPhase = ''
            mkdir -p $out/share/fcitx5/themes

            cp -r OriDark $out/share/fcitx5/themes/
            cp -r OriLight $out/share/fcitx5/themes/
          '';
        })
      ];
    };
  };

  # ============================================================================
  # Desktop Environment
  # ============================================================================

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Tell Chromium app to run on native supported Wayland, not XWayland
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
    enable = true;
    autoNumlock = true;
  };
  services.desktopManager.plasma6.enable = true;


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
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
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

  # ============================================================================
  # Font
  # ============================================================================


  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    jetbrains-mono
    ubuntu-sans
    liberation_ttf
    font-awesome
  ];

  fonts.fontconfig = {
    defaultFonts = {
      serif = [ "Noto Serif CJK TC" "Noto Serif" ];
      sansSerif = [ "Noto Sans CJK TC" "Ubuntu Sans" ];
      monospace = [ "JetBrains Mono" ];
    };
  };


  # ============================================================================
  # User Account
  # ============================================================================
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ryan = {
    isNormalUser = true;
    description = "ryan";
    group = "users";
    extraGroups = [
      "wheel"          # sudo
      "networkmanager"
      "video"
      "i2c"
      "input"
      "ydotool"   # 模擬打字
      "audio"
    ];
  };

  # ============================================================================
  # Programs
  # ============================================================================

  programs = {
    firefox.enable = true;
    git.enable = true;
    coolercontrol.enable = true;
    gnupg.agent = {
      enable = false;
      enableSSHSupport = true;
    };
    ydotool.enable = true;

  };

  # ============================================================================
  # Systemd
  # ============================================================================

  systemd.user.services.whisper-dictation = {
    description = "Whisper Dictation Service";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${inputs.whisper-dictation.packages.${pkgs.system}.default}/bin/whisper-dictation";
      Restart = "always";
    };
  };

  # ============================================================================
  # System Packages
  # ============================================================================
  nixpkgs.config.allowUnfree = true;

  services.syncthing = {
    enable = true;
    user = "ryan";
    dataDir = "/home/ryan";
    configDir = "/home/ryan/.config/syncthing";

    guiAddress = "0.0.0.0:8384";
  };

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    # loadModels = [ "gemma4:26b" ];
  };

  # services.ydotool.enable = true;

  environment.systemPackages = with pkgs; [

    # --- AI ---
    ollama

    # --- Whisper Dictation ---
    inputs.whisper-dictation.packages.${pkgs.system}.default
    pkgs.ydotool

    # --- Core Utilities ---
    wget
    curl
    git
    tree
    unzip
    zip
    file
    htop
    btop
    nvtopPackages.nvidia
    strace
    rsync
    bc
    xxd
    xz
    zstd

    # --- Development: C/C++ ---
    gcc
    gnumake
    cmake
    clang
    clang-tools     # clangd
    autoconf
    automake
    binutils
    gdb
    valgrind
    pkg-config

    # --- Development: Python ---
    python3
    python3Packages.pip
    python3Packages.virtualenv
    pipx

    # --- Text / Document Processing ---
    texliveFull     # TeX / LaTeX (texlive-full equivalent)
    # pandoc

    # --- Networking Tools ---
    nmap
    dsniff
    # tcpdump
    # wireshark
    ettercap
    # dnsutils        # dig, nslookup
    # whois
    # sslscan
    # sqlmap
    # ffuf
    # wapiti
    # whatweb

    # --- Json ---
    jq

    # --- Media ---
    ffmpeg
    # vlc
    # audacity
    # blender

    # --- Graphics / Image ---
    imagemagick
    # scrcpy          # Android screen mirroring

    # --- Database ---
    sqlite
    sqlitebrowser

    # --- System Tools ---
    lm_sensors
    ddcutil
    usbutils
    pciutils
    dmidecode
    efibootmgr
    smartmontools

  ];

  # ============================================================================
  # Nix Settings
  # ============================================================================
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
