{ config, pkgs, ... }:
{

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
  # Input Method
  # ============================================================================
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-chewing
      kdePackages.fcitx5-chinese-addons
      fcitx5-gtk
      libsForQt5.fcitx5-qt
      kdePackages.fcitx5-qt
      kdePackages.fcitx5-configtool
      # Ori-fcitx5 OriDark theme
      # https://github.com/Reverier-Xu/Ori-fcitx5
      (stdenvNoCC.mkDerivation {
        pname = "fcitx5-theme-ori";
        version = "unstable";
        src = fetchFromGitHub {
          owner = "Reverier-Xu";
          repo = "Ori-fcitx5";
          rev = "d2cf5df38f11e4e14dcf9436af5b9f8fa0087c55";  # 固定至具體 commit
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
}