{ config, pkgs, inputs,... }:
{  

  programs = {
      firefox.enable = true;
      coolercontrol.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      ydotool.enable = true;
      nix-ld.enable = true;
  };

  environment.systemPackages = with pkgs; [

    # --- Whisper Dictation ---
    inputs.whisper-dictation.packages.${pkgs.system}.default

    # --- Core Utilities ---
    git
    home-manager
    wget
    curl
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

    # --- Networking Tools ---
    nmap
    dsniff
    # tcpdump
    # wireshark
    # ettercap
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
    haruna # Haruna Player
    # vlc
    # audacity
    # blender

    # --- Graphics / Image ---
    imagemagick

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
}