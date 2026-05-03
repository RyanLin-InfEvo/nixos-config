{ stdenv
, lib
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, glibc
, gcc-unwrapped
, gtk3
, webkitgtk_4_1
, glib
, libsoup_3
, pango
, cairo
, gdk-pixbuf
, at-spi2-atk
, nss
, nspr
, alsa-lib
, libdrm
, mesa
, libX11
, expat
, libxkbcommon
}:

stdenv.mkDerivation rec {
  pname = "openwork";
  version = "0.11.212"; # 確保與 nixOS 25.11 環境下的版本號一致 [cite: 100]

  src = fetchurl {
    url = "https://github.com/different-ai/openwork/releases/download/v${version}/openwork-desktop-linux-amd64.deb";
    sha256 = "bX+1G/l5Y05/1utskNMP4V5I7gXU93jqPgOyabESpCg="; 
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];

  # 基於 TypeScript 的桌面應用程式通常依賴這些底層庫
  buildInputs = [
    glibc 
    gcc-unwrapped
    gtk3
    webkitgtk_4_1
    glib
    libsoup_3
    pango
    cairo
    gdk-pixbuf
    at-spi2-atk
    nss
    nspr
    alsa-lib
    libdrm
    mesa
    libX11
    expat
    libxkbcommon
  ];

unpackPhase = ''
    mkdir -p extracted
    ar p $src data.tar.gz | tar -xzf - -C extracted
  '';

  installPhase = ''
    mkdir -p $out

    # 1. 複製所有檔案
    cp -r extracted/usr/* $out/

    # 2. 解決衝突：移除 openwork 內建的 opencode 執行檔
    # 因為你在 home.packages 中已經安裝了獨立的 opencode 
    rm -f $out/bin/opencode

    # 3. 為主要執行檔建立包裝腳本，強制使用 X11 後端以解決 Wayland/X11 相容性問題
    if [ -f "$out/bin/OpenWork-Dev" ]; then
      mv $out/bin/OpenWork-Dev $out/bin/.OpenWork-Dev-unwrapped
      makeWrapper $out/bin/.OpenWork-Dev-unwrapped $out/bin/OpenWork-Dev \
        --set GDK_BACKEND x11
    fi
  '';

  meta = with lib; {
    description = "OpenWork Desktop - Open source Claude Cowork alternative";
    homepage = "https://github.com/different-ai/openwork";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
