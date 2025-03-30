{
  mkShell,
  gdb,
  nixd,
  zig,
  zls,
}:
mkShell {
  name = "zdb";
  packages = [
    zig
    gdb
    zls
    nixd
  ];
}
