{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = inputs: with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = pkgs.callPackage ./nix/devShell.nix {
          zig = zig.packages.${system}."0.14.0";
        };

        packages =
        let
          mkArgs = optimize: {
            inherit optimize;
          };
        in rec
        {
          zdb-debug = pkgs.callPackage ./nix/packages.nix (mkArgs "Debug");
          zdb-releasesafe = pkgs.callPackage ./nix/packages.nix (mkArgs "ReleaseSafe");
          zdb-releasefast = pkgs.callPackage ./nix/packages.nix (mkArgs "ReleaseFast");

          zdb = zdb-releasefast;
          default = zdb;
        };
      }
    );
    
}
