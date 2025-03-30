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

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
        zig = inputs.zig.packages.${system}."0.14.0";
      in
      {
        devShell = pkgs.callPackage ./nix/devShell.nix {
          inherit zig;
        };

        packages =
        let
          mkArgs = optimize: {
            inherit optimize zig;
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
