{ pkgs }:

pkgs.writeShellScriptBin "gitnexus" ''
  exec ${pkgs.nodejs}/bin/npx --yes gitnexus@1.6.0 "$@"
''
