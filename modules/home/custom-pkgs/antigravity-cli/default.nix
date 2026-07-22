{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "antigravity-cli";
  version = "1.1.5-5958982624477184";

  src = pkgs.fetchurl {
    url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.5-5958982624477184/linux-x64/cli_linux_x64.tar.gz";
    hash = "sha512-kGv/Wcc77WMCdPZ+/Hfj+iBk/hJvTXUhx+WNxnc9jR886GiPEXj372V3Zyj3gqjrwhEYlhfPu0Ln30j1YUrR9Q==";
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
