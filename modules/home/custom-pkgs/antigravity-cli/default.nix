{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "antigravity-cli";
  version = "1.1.7-5951805767680000";

  src = pkgs.fetchurl {
    url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.7-5951805767680000/linux-x64/cli_linux_x64.tar.gz";
    hash = "sha512-cg1af/JWql3WcSUTzV62/gMc+edSOjO8vad1USDO1Tu2T/mFtALOBo5YleD/s0jCYyVFA5od3m2q1ZHxZNWFLw==";
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
