{ pkgs }:

pkgs.writeShellScriptBin "gitnexus" ''
  exec ${pkgs.nodejs}/bin/npx --yes gitnexus@latest "$@"
''
