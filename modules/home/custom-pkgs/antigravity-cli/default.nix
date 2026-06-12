{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "antigravity-cli";
  version = "1.0.5-6195529869295616";

  src = pkgs.fetchurl {
    url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.5-6195529869295616/linux-x64/cli_linux_x64.tar.gz";
    sha256 = "sha256-+lLw0lybgCC9q3fFADhQeZ4VVKeSnOSbb+8oMX0Os9I=";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp antigravity $out/bin/agy
  '';

  meta = with pkgs.lib; {
    description = "Official Antigravity CLI";
    homepage = "https://antigravity.google";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
