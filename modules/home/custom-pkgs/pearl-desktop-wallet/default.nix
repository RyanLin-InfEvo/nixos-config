{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "pearl-desktop-wallet";
  version = "1.0.0";

  src = pkgs.fetchurl {
    url = "https://github.com/pearl-research-labs/pearl/releases/download/pearl-wallet-v1.0.0/pearl-desktop-wallet_1.0.0_amd64.deb";
    sha256 = "1ay3bxkmnxsnc46jwb08p1fsjwps2bxz4v3z4qhqnamq95i8rx2g";
  };

  nativeBuildInputs = [
    pkgs.dpkg
    pkgs.autoPatchelfHook
    pkgs.makeWrapper
  ];

  buildInputs = with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    xorg.libxshmfence
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    zlib
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  installPhase = ''
    mkdir -p $out/opt/pearl-desktop-wallet
    cp -r opt/Pearl\ Wallet/* $out/opt/pearl-desktop-wallet/

    # Copy share resources
    mkdir -p $out/share
    cp -r usr/share/* $out/share/

    # Fix execution path of desktop entry and rename desktop file if needed
    if [ -f $out/share/applications/@pearlpearl-desktop-wallet.desktop ]; then
      mv $out/share/applications/@pearlpearl-desktop-wallet.desktop $out/share/applications/pearl-desktop-wallet.desktop
      substituteInPlace $out/share/applications/pearl-desktop-wallet.desktop \
        --replace '"/opt/Pearl Wallet/@pearlpearl-desktop-wallet"' "$out/bin/pearl-desktop-wallet" \
        --replace "Icon=@pearlpearl-desktop-wallet" "Icon=pearl-desktop-wallet"
    fi

    # Handle icons
    if [ -d $out/share/icons/hicolor/564x564/apps ]; then
      mkdir -p $out/share/icons/hicolor/512x512/apps
      mv $out/share/icons/hicolor/564x564/apps/@pearlpearl-desktop-wallet.png $out/share/icons/hicolor/512x512/apps/pearl-desktop-wallet.png
      rm -rf $out/share/icons/hicolor/564x564
    fi

    # Create binary wrapper (adding --no-sandbox since Electron inside sandbox can fail on NixOS)
    mkdir -p $out/bin
    makeWrapper "$out/opt/pearl-desktop-wallet/@pearlpearl-desktop-wallet" "$out/bin/pearl-desktop-wallet" \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath buildInputs}" \
      --add-flags "--no-sandbox"
  '';

  meta = with pkgs.lib; {
    description = "Official Pearl Desktop Wallet";
    homepage = "https://github.com/pearl-research-labs/pearl";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
