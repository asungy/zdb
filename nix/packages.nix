{
  lib,
  optimize,
  stdenv,
  zig,
  pkgs,
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
    PACKAGE_DIR=${pkgs.callPackage ../build.zig.zon.nix {}}
    zig build install --global-cache-dir $(pwd)/.cache --system $PACKAGE_DIR -Doptimize=${optimize} --prefix $out
  '';
})
