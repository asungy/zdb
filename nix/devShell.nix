{
  mkShell,
  gdb,
  nixd,
  zig,
  zls,
  zon2nix,
}:
mkShell {
  name = "zdb";
  packages = [
    zig
    gdb
    zls
    nixd
    zon2nix
  ];
}
