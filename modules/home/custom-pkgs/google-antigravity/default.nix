{
  lib,
  stdenv,
  fetchurl,
  buildFHSEnv,
  autoPatchelfHook,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  writeShellScript,
  asar,
  bash,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  chromium,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
  libnotify,
  libsecret,
  libuuid,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemdLibs,
  vulkan-loader,
  libx11,
  libxscrnsaver,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxtst,
  libxcb,
  libxshmfence,
  libxkbfile,
  zlib,
  useFHS ? true,
  useSystemChromeProfile ? true,
  google-chrome ? null,
  extraBwrapArgs ? [],
  srcOverride ? null,
}: let
  pname = "google-antigravity";
  version = "100.0.0-6081531354152960";

  isAarch64 = stdenv.hostPlatform.system == "aarch64-linux";

  browserPkg =
    if isAarch64
    then chromium
    else if google-chrome != null
    then google-chrome
    else
      throw ''
        google-chrome is required on ${stdenv.hostPlatform.system} builds.
        Make sure you have allowUnfree = true or pass a google-chrome package.
      '';

  browserCommand =
    if isAarch64
    then "chromium"
    else "google-chrome-stable";

  browserProfileDir =
    if isAarch64
    then "$HOME/.config/chromium"
    else "$HOME/.config/google-chrome";

  finalSrc =
    if srcOverride != null
    then srcOverride
    else
      fetchurl {
        url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}/linux-x64/Antigravity.tar.gz";
        sha256 = "sha256-UDWduWkpG9VK9jVZygjK8f/jWreDQBrUzpPjnDdO0Ug=";
      };

  # Create a browser wrapper
  # When useSystemChromeProfile is true (default), forces use of the user's
  # existing Chrome profile so extensions are available to Antigravity.
  # When false, omits profile flags so Chrome runs with its own default
  # behavior, isolating Antigravity from the user's main profile.
  chrome-wrapper = writeShellScript "${browserCommand}-with-profile" ''
    set -euo pipefail

    system_browser="/run/current-system/sw/bin/${browserCommand}"
    browser_cmd="$system_browser"

    if [ ! -x "$system_browser" ]; then
      browser_cmd=${browserPkg}/bin/${browserCommand}
    fi

    exec "$browser_cmd" \
      ${lib.optionalString useSystemChromeProfile ''--user-data-dir="${browserProfileDir}" --profile-directory=Default''} \
      "$@"
  '';

  # Libraries loaded via dlopen() at runtime
  dlopenLibs = [
    libglvnd
    vulkan-loader
    systemdLibs
    libnotify
    libsecret
  ];

  # Libraries linked normally (resolved by autoPatchelf via rpath)
  linkedLibs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libuuid
    libxkbcommon
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
    libxshmfence
    libxkbfile
    zlib
  ];

  runtimeLibs = linkedLibs ++ dlopenLibs;

  desktopItem = makeDesktopItem {
    name = "antigravity";
    desktopName = "Google Antigravity";
    comment = "Next-generation agentic app";
    exec = "antigravity --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=auto --enable-wayland-ime=true --wayland-text-input-version=3 %U";
    icon = "antigravity";
    categories = ["Development" "Office"];
    startupNotify = true;
    startupWMClass = "Antigravity";
    mimeTypes = [
      "x-scheme-handler/antigravity"
    ];
  };

  meta = with lib; {
    description = "Google Antigravity - Next-generation agentic app";
    homepage = "https://antigravity.google";
    license = licenses.unfree;
    platforms = platforms.linux;
    maintainers = [];
    mainProgram = "antigravity";
  };

  # ── FHS variant (default) ──────────────────────────────────

  # Extract the upstream tarball without modification
  antigravity-unwrapped = stdenv.mkDerivation {
    pname = "${pname}-unwrapped";
    inherit version;
    src = finalSrc;

    dontBuild = true;
    dontConfigure = true;
    dontPatchELF = true;
    dontStrip = true;

    nativeBuildInputs = [asar];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/antigravity
      cp -r ./* $out/lib/antigravity/

      # Provide a dummy tunnel script to avoid ENOENT errors when running 'antigravity tunnel'
      mkdir -p $out/lib/antigravity/bin
      cat <<'EOF' > $out/lib/antigravity/bin/antigravity-tunnel
      #!/usr/bin/env bash
      echo "Remote tunneling is not supported in the Linux package of Google Antigravity because the required proprietary binary is not bundled." >&2
      exit 1
      EOF
      chmod +x $out/lib/antigravity/bin/antigravity-tunnel

      # Extract icon from app.asar
      asar ef $out/lib/antigravity/resources/app.asar icon.png
      cp icon.png $out/lib/antigravity/resources/antigravity.png

      runHook postInstall
    '';

    inherit meta;
  };

  # FHS environment for running Antigravity Agent App
  fhs = buildFHSEnv {
    name = "antigravity-fhs";
    targetPkgs = pkgs:
      runtimeLibs
      ++ [
        pkgs.udev
        pkgs.libudev0-shim
      ]
      ++ lib.optional (browserPkg != null) browserPkg;

    extraBwrapArgs = [
      "--bind-try /etc/nixos/ /etc/nixos/"
      "--ro-bind-try /etc/xdg/ /etc/xdg/"
      "--ro-bind-try /etc/nixpkgs/ /etc/nixpkgs/"
    ] ++ extraBwrapArgs;

    runScript = writeShellScript "antigravity-wrapper" ''
      # Set Chrome paths to use our wrapper that forces user profile
      export CHROME_BIN=${chrome-wrapper}
      export CHROME_PATH=${chrome-wrapper}

      exec ${antigravity-unwrapped}/lib/antigravity/antigravity "$@"
    '';

    inherit meta;
  };

  fhs-package = stdenv.mkDerivation {
    inherit pname version meta;

    dontUnpack = true;
    dontBuild = true;

    nativeBuildInputs = [copyDesktopItems];

    desktopItems = [desktopItem];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cat <<EOF > $out/bin/antigravity
#!/usr/bin/env bash
if [ "\$1" = "cli" ]; then
  shift
  exec agy "\$@"
elif [ "\$1" = "ide" ]; then
  shift
  exec antigravity-ide "\$@"
else
  exec ${fhs}/bin/antigravity-fhs "\$@"
fi
EOF
      chmod +x $out/bin/antigravity

      # Install icon from the app resources
      mkdir -p $out/share/pixmaps $out/share/icons/hicolor/1024x1024/apps
      cp ${antigravity-unwrapped}/lib/antigravity/resources/antigravity.png $out/share/pixmaps/antigravity.png
      cp ${antigravity-unwrapped}/lib/antigravity/resources/antigravity.png $out/share/icons/hicolor/1024x1024/apps/antigravity.png

      runHook postInstall
    '';
  };

  # ── Non-FHS variant ────────────────────────────────────────
  no-fhs-package = stdenv.mkDerivation {
    inherit pname version meta;
    src = finalSrc;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      copyDesktopItems
      asar
    ];

    buildInputs = runtimeLibs;

    runtimeDependencies = dlopenLibs;

    autoPatchelfIgnoreMissingDeps = [
      "libwebkit2gtk-4.1.so.0"
      "libsoup-3.0.so.0"
      "libcurl.so.4"
      "libcrypto.so.3"
    ];

    dontBuild = true;
    dontConfigure = true;

    desktopItems = [desktopItem];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/antigravity
      cp -r ./* $out/lib/antigravity/

      # Provide a dummy tunnel script to avoid ENOENT errors when running 'antigravity tunnel'
      cat <<'EOF' > $out/lib/antigravity/bin/antigravity-tunnel
      #!/usr/bin/env bash
      echo "Remote tunneling is not supported in the Linux package of Google Antigravity because the required proprietary binary is not bundled." >&2
      exit 1
      EOF
      chmod +x $out/lib/antigravity/bin/antigravity-tunnel

      # Extract icon from app.asar
      asar ef $out/lib/antigravity/resources/app.asar icon.png
      cp icon.png $out/lib/antigravity/resources/antigravity.png

      mkdir -p $out/bin
      cat <<EOF > $out/bin/antigravity
#!/usr/bin/env bash
if [ "\$1" = "cli" ]; then
  shift
  exec agy "\$@"
elif [ "\$1" = "ide" ]; then
  shift
  exec antigravity-ide "\$@"
else
  export CHROME_BIN="${chrome-wrapper}"
  export CHROME_PATH="${chrome-wrapper}"
  exec $out/lib/antigravity/antigravity "\$@"
fi
EOF
      chmod +x $out/bin/antigravity

      # Install icon from the app resources
      mkdir -p $out/share/pixmaps $out/share/icons/hicolor/1024x1024/apps
      cp $out/lib/antigravity/resources/antigravity.png $out/share/pixmaps/antigravity.png
      cp $out/lib/antigravity/resources/antigravity.png $out/share/icons/hicolor/1024x1024/apps/antigravity.png

      runHook postInstall
    '';
  };
in
  if useFHS
  then fhs-package
  else no-fhs-package
