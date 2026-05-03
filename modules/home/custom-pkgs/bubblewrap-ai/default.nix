{ lib, buildGoModule, fetchFromGitHub, makeWrapper, bubblewrap, bash }:

buildGoModule rec {
  pname = "bubblewrap-ai";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "umago";
    repo = "bubblewrap-ai";
    rev = "v${version}";
    sha256 = "1lvv2wbfjpdkb70ia8lffm7pw8pbr30qllkgyb07gfqmar16l7gq";
  };

  vendorHash = null;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace cmd/bwai/main.go \
      --replace '"bwrap"' '"${bubblewrap}/bin/bwrap"' \
      --replace '"bash"' '"${bash}/bin/bash"'

    sed -i '/"--ro-bind", "\/usr", "\/usr",/d' cmd/bwai/main.go
    sed -i '/"--ro-bind", "\/bin", "\/bin",/d' cmd/bwai/main.go
    sed -i '/"--ro-bind", "\/lib", "\/lib",/d' cmd/bwai/main.go
    sed -i '/"--ro-bind", "\/lib64", "\/lib64",/d' cmd/bwai/main.go
    sed -i '/"--ro-bind", "\/opt", "\/opt",/d' cmd/bwai/main.go
    sed -i '/"--tmpfs", "\/run",/d' cmd/bwai/main.go

    sed -i '/args = append(args, command...)/i \
	args = append(args, "--dir", "/nix", "--ro-bind", "/nix/store", "/nix/store")\
	args = append(args, "--dir", "/run", "--ro-bind", "/run/current-system", "/run/current-system")\
	args = append(args, "--symlink", "/run/current-system/sw/bin", "/bin")\
	args = append(args, "--dir", "/usr", "--symlink", "/run/current-system/sw/bin", "/usr/bin")\
	args = append(args, "--setenv", "PATH", "/run/current-system/sw/bin:/home/ryan/.nix-profile/bin:/bin:/usr/bin")\
	args = append(args, "--setenv", "LANG", "en_US.UTF-8")\
	args = append(args, "--setenv", "LOCALE_ARCHIVE", "/run/current-system/sw/lib/locale/locale-archive")\
    ' cmd/bwai/main.go
  '';

  subPackages = [ "cmd/bwai" ];

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Bubblewrap sandbox for AI coding agents";
    homepage = "https://github.com/umago/bubblewrap-ai";
    license = licenses.mit;
    maintainers = [ ];
  };
}
