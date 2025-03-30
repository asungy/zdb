{
  lib,
  optimize,
  stdenv,
  zig_0_14,
}: let
  zig_hook = zig_0_14.overrideAttrs {
    zig_default_flags = "-Doptimize=${optimize}";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zdb";
  version = "0.0.0";

  # Specify source files to limit rebuilds.
  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.intersection (lib.fileset.fromSource (lib.sources.cleanSource ../.)) (
      lib.fileset.unions [
        ../src
        ../build.zig
        ../build.zig.zon
      ]
    );
  };

  nativeBuildInputs = [
    zig_hook
  ];

  zigBuildFlags = [
    "-Dversion-string=${finalAttrs.version}-nix"
  ];
})
