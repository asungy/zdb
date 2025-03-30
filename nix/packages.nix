{
  lib,
  optimize,
  stdenv,
  zig,
}:
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

  nativeBuildInputs = [ zig ];

  dontConfigure = true;
  dontInstall = true;

  # TODO: Implement check phase.
  # doCheck = true;

  buildPhase = ''
    NO_COLOR=1
    zig build install --global-cache-dir $(pwd)/.cache -Doptimize=${optimize} --prefix $out
  '';
})
